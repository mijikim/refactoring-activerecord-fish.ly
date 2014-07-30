feature "Logged in user" do

  def register_user(username, password)
    visit "/"

    click_link "Register"

    fill_in "Username", with: username
    fill_in "Password", with: password

    click_button "Register"
  end

  before(:each) do
    register_user("Fred", "abcd")
  end

  scenario "can do see and delete other users" do
    visit "/"

    register_user("hoonta", "t0psecret")

    fill_in "Username", with: "hoonta"
    fill_in "Password", with: "t0psecret"

    click_button "Sign In"

    within ".user-list" do
      expect(page).to have_no_content "hoonta"
      expect(page).to have_content "Fred"

      click_button "Delete"
    end

    within ".user-list" do
      expect(page).to have_no_content "Fred"
    end
  end

  scenario "can do manage fish" do
    visit "/"

    register_user("hoonta", "t0psecret")

    fill_in "Username", with: "hoonta"
    fill_in "Password", with: "t0psecret"

    click_button "Sign In"

    click_link "New Fish"

    click_button "Create Fish"

    expect(page).to have_content "Name is required"
    expect(page).to have_content "Wikipedia page is required"

    fill_in "Wikipedia Page", with: "http://en.wikipedia.org/wiki/Coelacanth"
    click_button "Create Fish"

    expect(page).to have_content "Name is required"

    fill_in "Name", with: "Coelacanth"
    click_button "Create Fish"

    expect(page).to have_content "Wikipedia page is required"

    fill_in "Name", with: "coelacanth"
    fill_in "Wikipedia Page", with: "http://en.wikipedia.org/wiki/Coelacanth"
    click_button "Create Fish"

    expect(page).to have_content "Fish Created"

    click_link "New Fish"

    fill_in "Name", with: "Oarfish"
    fill_in "Wikipedia Page", with: "http://en.wikipedia.org/wiki/Oarfish"
    click_button "Create Fish"

    within ".fish-list" do
      expect(page).to have_content "coelacanth"
      expect(page).to have_content "Oarfish"
    end

    click_link "Oarfish"

    expect(page).to have_content "Oarfish"
    expect(page).to have_content "http://en.wikipedia.org/wiki/Oarfish"

    visit "/"

    click_button "Sign Out"

    register_user("another", "t0psecret")

    fill_in "Username", with: "another"
    fill_in "Password", with: "t0psecret"

    click_button "Sign In"

    within ".fish-list" do
      expect(page).to have_no_content "coelacanth"
    end
  end
end
