defmodule Explorer.Chain.Log do
  @moduledoc "Captures a Web3 log entry generated by a transaction"

  use Explorer.Schema

  alias Explorer.Chain.{Address, Data, Hash, Transaction}

  @required_attrs ~w(address_hash data index transaction_hash)a
  @optional_attrs ~w(first_topic second_topic third_topic fourth_topic type)a

  @typedoc """
   * `address` - address of contract that generate the event
   * `address_hash` - foreign key for `address`
   * `data` - non-indexed log parameters.
   * `first_topic` - `topics[0]`
   * `second_topic` - `topics[1]`
   * `third_topic` - `topics[2]`
   * `fourth_topic` - `topics[3]`
   * `transaction` - transaction for which `log` is
   * `transaction_hash` - foreign key for `transaction`.
   * `index` - index of the log entry in all logs for the `transaction`
   * `type` - type of event.  *Parity-only*
  """
  @type t :: %__MODULE__{
          address: %Ecto.Association.NotLoaded{} | Address.t(),
          address_hash: Hash.Address.t(),
          data: Data.t(),
          first_topic: String.t(),
          second_topic: String.t(),
          third_topic: String.t(),
          fourth_topic: String.t(),
          transaction: %Ecto.Association.NotLoaded{} | Transaction.t(),
          transaction_hash: Hash.Full.t(),
          index: non_neg_integer(),
          type: String.t() | nil
        }

  @primary_key false
  schema "logs" do
    field(:data, Data)
    field(:first_topic, :string)
    field(:second_topic, :string)
    field(:third_topic, :string)
    field(:fourth_topic, :string)
    field(:index, :integer, primary_key: true)
    field(:type, :string)

    timestamps()

    belongs_to(:address, Address, foreign_key: :address_hash, references: :hash, type: Hash.Address)

    belongs_to(:transaction, Transaction,
      foreign_key: :transaction_hash,
      primary_key: true,
      references: :hash,
      type: Hash.Full
    )
  end

  @doc """
  `address_hash` and `transaction_hash` are converted to `t:Explorer.Chain.Hash.t/0`.  The allowed values for `type`
  are currently unknown, so it is left as a `t:String.t/0`.

      iex> changeset = Explorer.Chain.Log.changeset(
      ...>   %Explorer.Chain.Log{},
      ...>   %{
      ...>     address_hash: "0x8bf38d4764929064f2d4d3a56520a76ab3df415b",
      ...>     data: "0x000000000000000000000000862d67cb0773ee3f8ce7ea89b328ffea861ab3ef",
      ...>     first_topic: "0x600bcf04a13e752d1e3670a5a9f1c21177ca2a93c6f5391d4f1298d098097c22",
      ...>     fourth_topic: nil,
      ...>     index: 0,
      ...>     second_topic: nil,
      ...>     third_topic: nil,
      ...>     transaction_hash: "0x53bd884872de3e488692881baeec262e7b95234d3965248c39fe992fffd433e5",
      ...>     type: "mined"
      ...>   }
      ...> )
      iex> changeset.valid?
      true
      iex> changeset.changes.address_hash
      %Explorer.Chain.Hash{
        byte_count: 20,
        bytes: <<139, 243, 141, 71, 100, 146, 144, 100, 242, 212, 211, 165, 101, 32, 167, 106, 179, 223, 65, 91>>
      }
      iex> changeset.changes.transaction_hash
      %Explorer.Chain.Hash{
        byte_count: 32,
        bytes: <<83, 189, 136, 72, 114, 222, 62, 72, 134, 146, 136, 27, 174, 236, 38, 46, 123, 149, 35, 77, 57, 101, 36,
                 140, 57, 254, 153, 47, 255, 212, 51, 229>>
      }
      iex> changeset.changes.type
      "mined"

  """
  def changeset(%__MODULE__{} = log, attrs \\ %{}) do
    log
    |> cast(attrs, @required_attrs)
    |> cast(attrs, @optional_attrs)
    |> validate_required(@required_attrs)
  end
end
