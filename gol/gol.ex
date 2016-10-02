# Any live cell with fewer than two live neighbours dies, as if caused by under-population.
# Any live cell with two or three live neighbours lives on to the next generation.
# Any live cell with more than three live neighbours dies, as if by over-population.
# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

defmodule Life do
  def board(w, l) do
    randomize_game(List.duplicate(List.duplicate(default_cell(), w), l))
  end

  defp default_cell do
    %{ state: false, should_toggle: false }
  end

  defp randomize_game(board) do
    Enum.map(board, fn row -> Enum.map(row, fn cell -> random_cell(cell) end) end) 
  end 
  
  defp random_cell(cell) do
    %{ state: random_state(cell[:state]), should_toggle: false }
  end

  defp random_state(state) do
    if (:random.uniform > 0.7), do: !state, else: state
  end

  defp print_board(board) do
    Enum.each(board, fn row -> 
      Enum.each(row, fn cell -> IO.write(if (cell[:state]), do: 'X ', else: '- ') end)
      IO.puts ''
    end)
    board
  end
  
  defp handle_fetch({:ok, value}) do
    value
  end

  defp handle_fetch(:error) do
    nil
  end
  
  defp get_cell(w, l, board) do
    row = handle_fetch(Enum.fetch(board, w))
    if (row), do: handle_fetch(Enum.fetch(row, l)), else: nil
  end

  defp bounds(bound, board) do
    lower_bound = if ((bound-1) < 0), do: 0, else: bound-1
    upper_bound = if ((bound+1) > Enum.count(board)-1), do: Enum.count(board)-1, else: bound+1
    lower_bound..upper_bound
  end

  defp live_area_count(w, l, board) do
    (Enum.filter(for x <- bounds(w, board), y <- bounds(l, board) do
      get_cell(x, y, board)
    end, fn cell -> cell && cell[:state] end) |> Enum.count())
  end

  defp live_neighbor_count(w, l, board) do
    cell = get_cell(w, l, board)
    area_cells = live_area_count(w, l, board)
    if (cell && cell[:state]), do: area_cells - 1, else: area_cells
  end

  defp toggle?(w, l, board) do
    neighbor_count = live_neighbor_count(w, l, board)
    cell = get_cell(w, l, board)
    (cell[:state] && (neighbor_count < 2 || neighbor_count > 3)) || (!cell[:state] && neighbor_count == 3)
  end

  defp should_toggle(should?, w, l, board) do
    cell = get_cell(w, l, board)
    %{ state: cell[:state], should_toggle: should? }
  end

  defp toggle(w, l, board) do
    cell = get_cell(w, l, board)
    %{ state: !cell[:state], should_toggle: cell[:should_toggle] }
  end

  defp calculate_next_game_state(board) do
    Enum.with_index(board) |> Enum.map(fn {row, w} -> Enum.with_index(row) |> Enum.map(fn {c, l} -> 
      if (toggle?(w, l, board)), do: should_toggle(true, w, l, board), else: should_toggle(false, w, l, board)
    end) end)
  end

  defp change_game_state(board) do
    Enum.with_index(board) |> Enum.map(fn {row, w} -> Enum.with_index(row) |> Enum.map(fn {c, l} -> 
      cell = get_cell(w, l, board)
      if (cell[:should_toggle]), do: toggle(w, l, board), else: cell
    end) end)
  end

  defp rest_and_clear_screen do
    :timer.sleep(100)
    IO.puts("\e[H\e[2J")
  end

  defp tick(board) do
    rest_and_clear_screen()
    calculate_next_game_state(board) |> change_game_state() |> print_board()
  end
  
  def loop(board) do
    board = tick(board)
    loop(board)
  end
end

Life.loop(Life.board(30, 30))
