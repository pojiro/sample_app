import Ecto.Query, warn: false
alias SampleApp.Repo
alias SampleApp.{Accounts, Accounts.User}
alias SampleApp.Multimedia

{:ok, user} = Accounts.register_admin_user(%{
  name:  "Example User",
  email: "example@railstutorial.org",
  password:              "foobar",
  password_confirmation: "foobar",
  admin: true
})
Accounts.activate_user(user)

Enum.each(1..100,
  fn n ->
    {:ok, user} = Accounts.register_user(%{
      name:  Faker.Name.En.name,
      email: "example-#{n}@railstutorial.org",
      password:              "password",
      password_confirmation: "password"
    })
    Accounts.activate_user(user)
  end
)

User
|> order_by([u], asc: u.inserted_at)
|> Repo.all()
|> Enum.take(6)
|> Enum.each(
     fn u ->
       Enum.each(1..50, fn _ ->
         Multimedia.create_micropost(%{
           content: Faker.Lorem.sentence(5),
           user_id: u.id
         })
       end)
     end
   )

users = Accounts.list_users()
user = List.first(users)

users
|> Enum.slice(1..-1)
|> Enum.each(&(Accounts.create_relationship(%{follower_id: user.id, followed_id: (&1).id})))

users
|> Enum.slice(2..-10)
|> Enum.each(&(Accounts.create_relationship(%{follower_id: (&1).id, followed_id: user.id})))
