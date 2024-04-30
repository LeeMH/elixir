defmodule LiveViewStudio.Volunteers.Volunteer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "volunteers" do
    field :name, :string
    field :phone, :string
    field :checked_out, :boolean, default: false

    timestamps()
  end

  @phone ~r/^\d{3}[\s-.]?\d{3}[\s-.]?\d{4}$/

  @doc false
  def changeset(volunteer, attrs) do
    volunteer
    |> cast(attrs, [:name, :phone, :checked_out])
    |> validate_required([:name, :phone])
    |> validate_length(:name, min: 2, max: 100, message: "이름을 2~100자 사이로 입력해주세요.")
    |> validate_format(:phone, @phone, message: "must be a valid phone number")
  end
end
