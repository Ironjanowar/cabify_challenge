# Car Pooling Service Challenge

Design/implement a system to manage car pooling.

At Cabify we provide the service of taking people from point A to point B.
So far we have done it without sharing cars with multiple groups of people.
This is an opportunity to optimize the use of resources by introducing car
pooling.

You have been assigned to build the car availability service that will be used
to track the available seats in cars.

Cars have a different amount of seats available, they can accommodate groups of
up to 4, 5 or 6 people.

People requests cars in groups of 1 to 6. People in the same group want to ride
on the same car. You can take any group at any car that has enough empty seats
for them. If it's not possible to accommodate them, they're willing to wait.

Once they get a car assigned, they will journey until the drop off, you cannot
ask them to take another car (i.e. you cannot swap them to another car to
make space for another group). In terms of fairness of trip order: groups are
served in the order they arrive, but they ride opportunistically.

For example: a group of 6 is waiting for a car and there are 4 empty seats at
a car for 6; if a group of 2 requests a car you may take them in the car for
6 but only if you have nowhere else to make them ride. This may mean that the
group of 6 waits a long time, possibly until they become frustrated and
leave.

## Acceptance

The acceptance test step in the `.gitlab-ci.yml` must pass before you submit
your solution. We will not accept any solutions that do not pass or omit this
step.

## API

To simplify the challenge and remove language restrictions, this service must
provide a REST API which will be used to interact with it.

This API must comply with the following contract:

### GET /status

Indicate the service has started up correctly and is ready to accept requests.

Responses:

* **200 OK** When the service is ready to receive requests.

### PUT /cars

Load the list of available cars in the service and remove all previous data
(existing journeys and cars). This method may be called more than once during
the life cycle of the service.

**Body** _required_ The list of cars to load.

**Content Type** `application/json`

Sample:

```json
[
  {
    "id": 1,
    "seats": 4
  },
  {
    "id": 2,
    "seats": 7
  }
]
```

Responses:

* **200 OK** When the list is registered correctly.
* **400 Bad Request** When there is a failure in the request format, expected
  headers, or the payload can't be unmarshaled.

### POST /journey

A group of people requests to perform a journey.

**Body** _required_ The group of people that wants to perform the journey

**Content Type** `application/json`

Sample:

```json
{
  "id": 1,
  "people": 4
}
```

Responses:

* **200 OK** or **202 Accepted** When the group is registered correctly
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshaled.

### POST /dropoff

A group of people requests to be dropped off. Wether they traveled or not.

**Body** _required_ A form with the group ID, such that `ID=X`

**Content Type** `application/x-www-form-urlencoded`

Responses:

* **200 OK** or **204 No Content** When the group is unregistered correctly.
* **404 Not Found** When the group is not to be found.
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshaled.

### POST /locate

Given a group ID such that `ID=X`, return the car the group is traveling
with, or no car if they are still waiting to be served.

**Body** _required_ A url encoded form with the group ID such that `ID=X`

**Content Type** `application/x-www-form-urlencoded`

**Accept** `application/json`

Responses:

* **200 OK** With the car as the payload when the group is assigned to a car.
* **204 No Content** When the group is waiting to be assigned to a car.
* **404 Not Found** When the group is not to be found.
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshaled.

## Tooling

In this repo you may find a [.gitlab-ci.yml](./.gitlab-ci.yml) file which
contains some tooling that would simplify the setup and testing of the
deliverable. This testing can be enabled by simply uncommenting the final
acceptance stage.

Additionally, you will find a basic Dockerfile which you could use a
baseline, be sure to modify it as much as needed, but keep the exposed port
as is to simplify the testing.

You are free to modify the repository as much as necessary to include or remove
dependencies, but please document these decisions using MRs or in this very
README adding sections to it, the same way you would be generating
documentation for any other deliverable. We want to see how you operate in a
quasi real work environment.

# Solution

## About the repository

The main solution is in the `master` branch, there is a `database`
branch with a version of the solution using PostgreSQL. I had to do
this because I needed `docker-compose` in order to deploy correctly
the application using `gitlab-ci`, but I wanted to keep it simple so I
decided to develop a "memory database" version that uses a `GenServer`
to store the state of the application.

## Why Phoenix?

I decided to use the Phoneix framework to create the API. It gives
useful generated code for the Endpoint, Router, Controller and
Views. It also provides a known structure of modules, so anyone that
knows Phoenix will understand this solution (at least the non-logic
related).

## Config

The config is pretty much standard except for:
 - Default port changed to 9091 on `prod`.
 - Server was set to true in `CarPoolingChallengeWeb.Endpoint` so the
   release works.

## Thought process

In the application will exist two entities:
  - **Cars**: that have three attributes:
    + _id_: Unique identifier of a car
    + _seats_: Seats that the car has
    + _free\_seats_: Seats that are not occupied
  - **Groups**: that have three attributes also:
    + _id_: Unique identifier of a group
    + _people_: Amount of people of the group
    + _car\_id_: Id of the car where this group is located or `nil` if
      they are waiting for a car
    + _inserted\_at_: A `DateTime` with the time when the group was
      inserted

There is a `GroupAssigner` module that is in charge of assign cars to
groups via an async `Task`, this module is going to be called every
time there is a `/cars`, `/journey` or `/dropoff` request. It would
get the groups ordered by "waiting time" so the groups that have been
longer time waiting are assigned first.

There is also a `MemoryDatabase` module that is a `GenServer`, it
manages the state of the application. The internal state of the
`GenServer` consist of a map of maps with a format like the one below:
```elixir
%{
  cars: %{
    1 => %CarPoolingChallenge.Model.Car{
        id: 1,
        seats: 4,
        free_seats: 2
    }
  },
  groups: %{
    1 => %CarPoolingChallenge.Model.Group{
      id: 1,
      people: 2,
      car_id: 1,
      inserted_at: ~U[2019-08-02 18:05:18.565200Z]
    }
  }
}
```

I used maps insead of lists because searching several times for groups
and cars in a list would be a lot less efficient.

## Modules

### Application

Starts up the app and the `CarPoolingChallenge.MemoryDatabase` module,
which is in charge of storing the state of the application.
