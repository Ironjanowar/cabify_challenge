defmodule CarPoolingChallenge.MemoryDatabase do
  use GenServer

  alias CarPoolingChallenge.Model.Group

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  # Client API
  def start_link() do
    GenServer.start_link(__MODULE__, %{cars: %{}, groups: %{}}, name: __MODULE__)
  end

  def insert(data) do
    GenServer.call(__MODULE__, {:insert, data})
  end

  def get_group(id) do
    GenServer.call(__MODULE__, {:get_group, id})
  end

  def delete_group(id) do
    GenServer.call(__MODULE__, {:delete_group, id})
  end

  def get_unassigned_groups() do
    GenServer.call(__MODULE__, :get_unassigned_groups)
  end

  def get_car(id) do
    GenServer.call(__MODULE__, {:get_car, id})
  end

  def get_free_cars() do
    GenServer.call(__MODULE__, :get_free_cars)
  end

  def free_seats(car_id, people) do
    GenServer.cast(__MODULE__, {:free_seats, car_id, people})
  end

  def new_journey(group, car) do
    GenServer.cast(__MODULE__, {:new_journey, group, car})
  end

  # Server callbacks
  # CALL
  def init(state) do
    {:ok, state}
  end

  def handle_call({:insert, group = %Group{}}, _from, state) do
    # Check if id already exists
    if get_in(state, [:groups, group.id]) |> is_nil do
      # Add the new group
      new_state = update_in(state, [:groups, group.id], fn _ -> group end)
      {:reply, {:ok, group}, new_state}
    else
      {:reply, {:error, :id_exists}, state}
    end
  end

  def handle_call({:insert, cars}, _from, state) do
    groups = Map.get(state, :groups)

    # Remove all assigned groups
    new_groups =
      Enum.filter(groups, fn {_, group} -> group.car_id |> is_nil end) |> Enum.into(%{})

    cars_map = Enum.map(cars, fn car -> {car.id, car} end) |> Enum.into(%{})

    # Remove all the cars
    new_state = %{cars: cars_map, groups: new_groups}
    {:reply, {:ok, cars}, new_state}
  end

  def handle_call({:get_group, id}, _from, state) do
    case get_in(state, [:groups, id]) do
      nil -> {:reply, {:error, :not_found}, state}
      group -> {:reply, {:ok, group}, state}
    end
  end

  def handle_call({:delete_group, id}, _from, state) do
    case pop_in(state, [:groups, id]) do
      {nil, _} -> {:reply, {:error, :not_found}, state}
      {group, new_state} -> {:reply, {:ok, group}, new_state}
    end
  end

  def handle_call(:get_unassigned_groups, _from, %{groups: groups} = state) do
    unassigned_groups =
      Enum.filter(groups, fn {_, group} -> group.car_id |> is_nil end)
      |> Enum.sort_by(fn {_, group} -> group.inserted_at |> DateTime.to_unix() end)
      |> Enum.map(&elem(&1, 1))

    {:reply, unassigned_groups, state}
  end

  def handle_call({:get_car, id}, _from, state) do
    case get_in(state, [:cars, id]) do
      nil -> {:reply, {:error, :not_found}, state}
      car -> {:reply, {:ok, car}, state}
    end
  end

  def handle_call(:get_free_cars, _from, %{cars: cars} = state) do
    filtered_cars =
      Enum.filter(cars, fn {_, car} -> car.free_seats > 0 end) |> Enum.map(&elem(&1, 1))

    {:reply, filtered_cars, state}
  end

  # CAST
  def handle_cast({:free_seats, car_id, people}, state) do
    new_state =
      update_in(state, [:cars, car_id], fn c ->
        Map.update(c, :free_seats, c.free_seats, &(&1 + people))
      end)

    {:noreply, new_state}
  end

  def handle_cast({:new_journey, group, car}, state) do
    # Add the car id to the group and update the free seats in the car
    new_state =
      update_in(state, [:groups, group.id], fn g ->
        Map.update(g, :car_id, nil, fn _ -> car.id end)
      end)
      |> update_in([:cars, car.id], fn c ->
        Map.update(c, :free_seats, car.free_seats, &(&1 - group.people))
      end)

    {:noreply, new_state}
  end
end
