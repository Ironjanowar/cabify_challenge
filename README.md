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

There is a `GroupAssigner` module that is in charge of assigning cars
to groups via an async `Task`, this module is going to be called every
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

The cars and groups are always removed when not needed. In a
production service it may be useful to store all the data, but since
this is a challenge and it will complicate the solution, all data is
deleted. Also, to store the deleted data I will create another table
for each entity (for analysis only) creating a primary key with the id
and the current time, in order to store multiple cars or groups with
the same id in different timestamps.

## Dependencies

This are the project dependencies used in this application:
  - **Phoenix**: For the API and all the project structure
  - **Ecto**: For the model validation.
  - **Jason**: For serialization and deserialization.

## Router and controllers

There are two pipelines, one that accepts `json` only and another one
that accepts `json` and `urlencoded`. The routes piping throgh the
`json` only are:
  - `get("/status", StatusController, :status)`: Gets a `200 OK` as
    response, it is a health check.
  - `put("/cars", CarsController, :set_cars)`: Validates the input
    parameters and creates the given cars removing the ones that
    already exist.
  - `post("/journey", JourneyController, :journey)`: Validates the
    input parameters and assigns a car to a group if possible.

The routes piping through the `json` and `urlencoded` are:
  - `post("/dropoff", JourneyController, :dropoff)`: Validates the
    input parameters and if possible removes the given group from the
    system and frees the seats that were occupied by it (in case the
    group was assigned to a car).
  - `post("/locate", JourneyController, :locate)`: Validates the input
    parameters and tries to find a group in the system.

All the routes have a `match(:*, "/path", FallbackController,
:invalid_method)` that matches all the valid paths with wrong verbs to
send a `405 Method not allowed` error.

## Modules

### CarPoolingChallenge.Application

Starts up the app and the `CarPoolingChallenge.MemoryDatabase` module,
which is in charge of storing the state of the application.

### CarPoolingChallenge.Model.Car

Defines the struct of a car with the attributes shown in the
[**Thought process**](#thought-process) section. Has several
functions:
  - _changeset(attrs)_: Uses `Ecto` to validate the format of `atttrs`
      and check if a valid car can be created.
  - _insert\_all(cars)_: Receives a list of `cars`, deletes all the
    existing cars and inserts the given `cars` in the storage calling
    `CarPoolingChallenge.MemoryDatabase` module.
  - _get(id)_: Receives an id and calls
    `CarPoolingChallenge.MemoryDatabase` to get it from the storage.
  - _check\_params(car)_: Receives a map and tries to create a car
    from it checking the parameters with `&changeset/1` and applying
    the changes if the result changeset is valid.
  - _get\_free\_cars()_: Gets all the cars that have one or more seats
    available.
  - _free\_seats(car\_id, people)_: Free a given number of seats
    (`people`) from a car (`car_id`).

### CarPoolingChallenge.Model.Group

Defines the struct of a group with the attributes shown in the
[**Thought process**](#thought-process) section. Has several
functions:
  - _changeset(attrs)_: Uses `Ecto` to validate the format of `attrs`
    and check if a valid group can be created.
  - _new(attrs)_: Checks and inserts (if possible) a group with the
    givet `attrs`
  - _get(id)_: Receives an id and call
    `CarPoolingChallenge.MemoryDatabase` to get it from the storage.
  - _delete(id)_: Deletes a given group by `id`.
  - _get\_unassigned\_groups()_: Return all the groups that do not
    have a car assigned.
  - _new\_journey(group, car)_: Assigns a given `group` to a given
    `car`.

**Note:** Cars do not have a `&new/1` function that inserts directly
into the storage because each car is checked in the controller before
passing it to the logic.

### CarPoolingChallenge.GroupAssigner

This module is in charge of an efficient assigment of cars to
groups. Has a function called `&assign/0` that creates an async task
to assign the cars.

It has the following functions:
  - _assign()_: Creates a task that gets all the unassigned groups and
    tries to assign a car to each one, prioritizing the ones that have
    been waiting a longer time.
  - _dropoff(id)_: Deletes a given group from the storage and the car
    (if it is assigned to one)

This module has a private function `&assign_car/1` that assigns a
group to a car leaving the less free seats possible.

### CarPoolingChallenge.MemoryDatabase

This module acts as a database, storing the state of the
application. It is a `GenServer` that has the following functions:
  - _child\_spec()_: Defines the way it should be started.
  - _start\_link()_: Starts the `GenServer` with the default state
    `%{cars: %{}, groups: %{}}` and with the name
    `CarPoolingChallenge.MemoryDatabase`. This means that this is a
    named `GenServer` not meant to be replicated.
  - _insert(data)_: Inserts a car or a group into the database, the
    type is pattern matched in the handlers.
  - _get\_group(id)_: Gets a group by a given id.
  - _delete\_group(id)_: Deletes a group byy a given id.
  - _get\_unassigned\_groups()_: Gets all unassigned groups ordered in
    ascending order by its `inserted_at` attribute.
  - _get\_car(id)_: Gets a car by a given id.
  - _get\_free\_cars()_: Gets all cars that have one or more free
    seats.
  - _free\_seats(car\_id, people)_: Frees the amount of seats
    determined by `people` of the car determined by `car_id`. This
    function is executed asynchronously via `GenServer.cast`.
  - _new\_journey(group, car)_: Assigns the `group` to a `car`, adding
    the `car.id` to the group and updating the free seats in the
    `car`. This function is executed asynchronously via
    `GenServer.cast`.

This module could have been an `Agent`, it is easier to update and
maintains bigger states. But I defined a `GenServer` just in case the
module needed to do more than just store and update the state.

## Deployment

This project uses `docker` to deploy, the `Dockerfile` gets all the
needed dependencies, sets the environment variables, compiles the
project, creates a release using the `mix release` command and
executes the binary generated.

## Trouble with gitlab CI

I had some trouble using gitlab CI, the docker container could not be
reached by the `harness` tests in the `acceptance` stage. After
several tests and Google searches I found [this
comment](https://gitlab.com/charts/gitlab/issues/478#note_199237922)
from @vovkd that suggests removing `DOCKER_HOST: tcp://docker:2375`
from the config. I tried that and it worked for me, but just some
minutes after, I pushed to the repository some docs only and it
failed. I put again the `DOCKER_HOST: tcp://docker:2375` and again
started to work.

This got me very confused a phew days, but it works now with the
memory database version.
