defmodule ExEffectiveBootstrap.Feedback do
  @moduledoc "Used by Options to generate the valid and invalid feedback"
  alias Phoenix.HTML.Form

  @valid {:safe, "Look's good!"}
  @invalid {:safe, "is invalid"}

  @spec valid(ExEffectiveBootstrap.Options.t(), Phoenix.HTML.FormData.t(), atom) :: Phoenix.HTML.Safe.t()
  def valid(_options, _form, _field), do: @valid

  @spec invalid(ExEffectiveBootstrap.Options.t(), Phoenix.HTML.FormData.t(), atom) :: Phoenix.HTML.Safe.t()
  def invalid(options, form, field) do
    error = errors(form, field)
    validation = validations(form, field, options)
    feedback = feedbacks(form, field, options)

    invalid_text(error ++ validation ++ feedback)
  end

  defp invalid_text(messages) when length(messages) == 0, do: @invalid

  defp invalid_text(messages) do
    {:safe, messages |> List.flatten() |> Enum.uniq() |> Enum.join(" and ")}
  end

  defp errors(form, field) do
    Keyword.get_values(form.source.errors, field)
    |> Enum.map(fn {msg, opts} -> error(msg, opts) end)
  end

  defp error(msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      if is_nil(value), do: acc, else: String.replace(acc, "%{#{key}}", "#{value}")
    end)
  end

  defp validations(form, field, options) do
    Form.input_validations(form, field)
    |> Keyword.put(:required, options.required)
    |> Enum.map(fn {msg, opts} -> validation(msg, opts) end)
  end

  defp validation(:required, true), do: ["can't be blank"]
  defp validation(:required, _), do: []
  defp validation(:minlength, count), do: ["should be at least #{count} character(s)"]
  defp validation(:maxlength, _), do: []
  defp validation(unknown, opts), do: ["unknown validation #{unknown} #{opts}"]

  defp feedbacks(_form, _field, options) do
    feedback(options.type)
  end

  defp feedback(:email_input), do: ["must be an email"]
  defp feedback(:telephone_input), do: ["must be a phone number"]
  defp feedback(_), do: []
end
