defmodule Account do
  defstruct user: User, balance: 1000
  @accounts "accounts.txt"

  def create_account(user) do
    case find_by_email(user.email) do
      nil ->
        module = [%__MODULE__{user: user}]
        |> :erlang.term_to_binary()
        File.write(@accounts, module)
      %Account{balance: balance, user: user} ->
        module = [%__MODULE__{user: user}] ++ find_accounts()
        |> :erlang.term_to_binary()
        File.write(@accounts, module)
      _ -> {:error, "Account already exists"}
    end
  end

  def find_by_email(email), do: Enum.find(find_accounts(), &(&1.user.email == email))

  def find_accounts() do
    {:ok, accounts} = case File.read(@accounts) do
      {:ok, accounts} -> {:ok, accounts}
      _ -> []
    end
    cond do
      String.length(accounts) > 0 -> :erlang.binary_to_term(accounts)
      true -> []
    end
  end

  def transfer(from, to, value) do
    from = find_by_email(from.user.email)

    cond do
      balance_validation(from.balance, value) -> {:error, "Saldo insuficiente"}
      true ->
        accounts = find_accounts()
        accounts = List.delete accounts, from
        accounts = List.delete accounts, to
        from = %Account{to | balance: from.balance - value}
        to = %Account{to | balance: to.balance + value}
        accounts = accounts ++ [from, to]
        File.write(@accounts, :erlang.term_to_binary(accounts))
    end
  end

  def withdraw(account, value) do
    cond do
      balance_validation(account.balance, value) -> {:error, "Saldo insuficiente"}
      true ->
        account = %Account{account | balance: account.balance - value}
        {:ok, account, "Mensagem de email encaminhada"}
    end
  end

  defp balance_validation(balance, value), do: balance < value
end