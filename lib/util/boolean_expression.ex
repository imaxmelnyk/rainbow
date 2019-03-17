defmodule Util.BooleanExpression do
  alias Util.BooleanExpression.ParseError
  alias Util.BooleanExpression.ExecError
  alias Util.Option

  @type t_not :: {:not, t | String.t}
  @type t_and :: {:and, t | String.t, t | String.t}
  @type t_or :: {:or, t | String.t, t | String.t}

  @type t_logical :: t_not | t_and | t_or | String.t

  @type t_eq :: {:eq, String.t | float, String.t | float}
  @type t_ne :: {:ne, String.t | float, String.t | float}
  @type t_lt :: {:lt, String.t | float, String.t | float}
  @type t_le :: {:le, String.t | float, String.t | float}
  @type t_gt :: {:gt, String.t | float, String.t | float}
  @type t_ge :: {:ge, String.t | float, String.t | float}

  @type t_comparison :: t_eq | t_ne | t_lt | t_le | t_gt | t_ge

  @type t :: t_logical | t_comparison

  @spec exec(t, map) :: Option.t(boolean, ExecError.t)
  def exec(expr, variables) do
    case expr do
      expr when is_binary(expr) -> get_variable(expr, variables, &(is_boolean(&1)))
      {:not, expr} ->
        expr
        |> exec(variables)
        |> Option.map(fn val -> !val end)
      {:and, left, right} ->
        left
        |> exec(variables)
        |> Option.flat_map(fn left ->
          right
          |> exec(variables)
          |> Option.map(fn right -> left && right end)
        end)
      {:or, left, right} ->
        left
        |> exec(variables)
        |> Option.flat_map(fn left ->
          right
          |> exec(variables)
          |> Option.map(fn right -> left || right end)
        end)
      {comparison_operator, left, right} when comparison_operator in [:eq, :ne] ->
        left_option = get_variable(left, variables, &(is_number(&1) || is_binary(&1)))
        right_option = get_variable(right, variables, &(is_number(&1) || is_binary(&1)))

        Option.flat_map(left_option, fn left ->
          Option.flat_map(right_option, fn right ->
            case {left, right} do
              {left, right} when (is_binary(left) and is_binary(right)) or (is_number(left) and is_number(right)) ->
                case comparison_operator do
                  :eq -> {:ok, left == right}
                  :ne -> {:ok, left != right}
                end
              _ -> {:error, %ExecError{message: "Invalid boolean expression."}}
            end
          end)
        end)
      {comparison_operator, left, right} ->
        left_option = get_variable(left, variables, &(is_number(&1)))
        right_option = get_variable(right, variables, &(is_number(&1)))

        Option.flat_map(left_option, fn left ->
          Option.flat_map(right_option, fn right ->
            case comparison_operator do
              :lt -> {:ok, left < right}
              :le -> {:ok, left <= right}
              :gt -> {:ok, left > right}
              :ge -> {:ok, left >= right}
              _ -> {:error, %ExecError{message: "Invalid boolean expression."}}
            end
          end)
        end)
      _ -> {:error, %ExecError{message: "Invalid boolean expression."}}
    end
  end

  @spec parse(String.t) :: Option.t(t, ParseError.t)
  def parse(expr) do
    expr
    |> parse_parentheses()
    |> Option.flat_map(fn {expr, variables} ->
      expr
      |> parse_operators()
      |> Option.map(&({&1, variables}))
    end)
    |> Option.flat_map(fn {expr, variables} ->
      variables
      |> Enum.map(fn {key, val} -> {key, parse_operators(val)} end)
      |> Option.from_map()
      |> Option.map(&({expr, &1}))
    end)
    |> Option.flat_map(fn {expr, variables} ->
      replace_variables(expr, variables)
    end)
  end

  @spec parse_parentheses(String.t, map) :: Option.t({String.t, map}, ParseError.t)
  defp parse_parentheses(expr, variables \\ %{}) do
    regex = ~r/\(([a-zA-Z0-9_\-\. <>=!|&]*?)\)/

    case Regex.scan(regex, expr) do
      [] ->
        cond do
          String.contains?(expr, ["(", ")"]) -> {:error, %ParseError{message: "Error during parsing parentheses."}}
          true -> {:ok, {expr, variables}}
        end
      matches ->
        {expr, variables} =
          matches
          |> Enum.uniq()
          |> Enum.reduce({expr, variables}, fn [expr_wb, expr_wob], {expr, variables} ->
            key = kinda_random_string()
            {String.replace(expr, expr_wb, key), Map.put(variables, key, expr_wob)}
          end)
        parse_parentheses(expr, variables)
    end
  end

  @spec parse_operators(String.t) :: Option.t(t, ParseError.t)
  defp parse_operators(expr) do
    expr
    |> parse_logical_operators()
    |> Option.flat_map(&(parse_comparison_operators(&1)))
  end

  @spec parse_logical_operators(String.t) :: Option.t(t_logical, ParseError.t)
  defp parse_logical_operators(expr) do
    regex = ~r{ \|\| | && }

    case String.split(expr, regex, include_captures: true) |> Enum.reverse() do
      [left, operator | right] ->
        left_option = parse_logical_operators(left)
        right_option =
          right
          |> Enum.reverse()
          |> Enum.join()
          |> parse_logical_operators()

        Option.flat_map(left_option, fn left ->
          Option.flat_map(right_option, fn right ->
            case operator do
              " || " -> {:ok, {:or, left, right}}
              " && " -> {:ok, {:and, left, right}}
              _ -> {:error, %ParseError{message: "Error during parsing logical operators."}}
            end
          end)
        end)
      _ ->
        case expr do
          "!" <> expr -> {:ok, {:not, expr}}
          _ -> {:ok, expr}
        end
    end
  end

  @spec parse_comparison_operators(t_logical) :: Option.t(t, ParseError.t)
  defp parse_comparison_operators(expr) do
    regex = ~r{ == | != | < | <= | > | >= }

    case expr do
      {logic, expr} ->
        expr
        |> parse_comparison_operators()
        |> Option.map(&({logic, &1}))
      {logic, left, right} ->
        left_option = parse_comparison_operators(left)
        right_option = parse_comparison_operators(right)

        Option.flat_map(left_option, fn left ->
          Option.map(right_option, fn right ->
            {logic, left, right}
          end)
        end)
      _ ->
        case String.split(expr, regex, include_captures: true) do
          [left, operator, right] ->
            left =
              case Float.parse(left) do
                {left, ""} -> left
                _ -> left
              end
            right =
              case Float.parse(right) do
                {right, ""} -> right
                _ -> right
              end

            case operator do
              " == " -> {:ok, {:eq , left, right}}
              " != " -> {:ok, {:ne , left, right}}
              " < " -> {:ok, {:lt , left, right}}
              " <= " -> {:ok, {:le , left, right}}
              " > " -> {:ok, {:gt , left, right}}
              " >= " -> {:ok, {:ge , left, right}}
              _ -> {:error, %ParseError{message: "Error during parsing comparison operators."}}
            end
          _ -> is_variable(expr)
        end
    end
  end

  @spec replace_variables(t, map) :: Option.t(t, ParseError.t)
  defp replace_variables(expr, variables) do
    case Map.keys(variables) do
      [] -> {:ok, expr}
      _ ->
        case expr do
          "true" -> {:ok, true}
          "false" -> {:ok, false}
          variable when is_binary(variable) -> {:ok, Map.get(variables, variable, variable)}
          constant when is_float(constant) -> {:ok, constant}
          {operator, variable} ->
            variable_option =
              cond do
                is_binary(variable) -> {:ok, Map.get(variables, variable, variable)}
                true -> replace_variables(variable, variables)
              end

            Option.map(variable_option, &({operator, &1}))
          {operator, left, right} ->
            left_option =
              cond do
                is_binary(left) -> {:ok, Map.get(variables, left, left)}
                true -> replace_variables(left, variables)
              end
            right_option =
              cond do
                is_binary(right) -> {:ok, Map.get(variables, right, right)}
                true -> replace_variables(right, variables)
              end

            Option.flat_map(left_option, fn left ->
              Option.map(right_option, fn right ->
                {operator, left, right}
              end)
            end)
          _ -> {:error, %ParseError{message: "Error during replacing variables."}}
        end
    end
  end

  @spec get_variable(any, map, (any -> boolean)) :: Option.t(any, ExecError.t)
  defp get_variable(variable, variables, check_type) do
    cond do
      is_binary(variable) ->
        case Map.get(variables, variable, variable) do
          value ->
            cond do
              check_type.(value) -> {:ok, value}
              true -> {:error, %ExecError{message: "The variable with name: '#{variable}', has wrong type."}}
            end
        end
      true -> {:error, %ExecError{message: "Invalid boolean expression."}}
    end
  end

  @spec is_variable(any) :: Option.t(String.t, ParseError.t)
  defp is_variable(variable) do
    regex = ~r/[a-zA-Z0-9_]/
    cond do
      !is_binary(variable) -> {:error, %ParseError{message: "Error during parsing variable."}}
      Regex.match?(regex, variable) -> {:ok, variable}
      true -> {:error, %ParseError{message: "Error during parsing variable name."}}
    end
  end

  @spec kinda_random_string() :: String.t
  defp kinda_random_string() do
    random_number = :rand.uniform(9999)
    "key#{random_number}"
  end
end
