alias SampleApp.{Accounts}

Accounts.register_admin_user(%{
  name:  "Example User",
  email: "example@railstutorial.org",
  password:              "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  activated_at: NaiveDateTime.utc_now()
})

Enum.each(1..100,
  fn n ->
    Accounts.register_user(%{
      name:  Faker.Name.En.name,
      email: "example-#{n}@railstutorial.org",
      password:              "password",
      password_confirmation: "password",
      activated: true,
      activated_at: NaiveDateTime.utc_now()
    })
  end
)