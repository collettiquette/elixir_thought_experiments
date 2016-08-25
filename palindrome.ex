defmodule Palindrome do
  def find_all(word) do
    Enum.filter(substrings(word), &palindrome?/1)
  end 

  defp palindrome?(word) do
    word == String.reverse(word) && String.length(word) > 1
  end

  defp substrings(word) do
    Enum.uniq(for x <- 0..String.length(word), y <- String.length(word)..0 do
      String.slice(word, x, y)
    end)
  end
end

for palindrome <- Palindrome.find_all("racecarracecar") do
  IO.puts palindrome
end
