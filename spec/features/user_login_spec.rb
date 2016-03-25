feature 'User management: log in' do

  scenario 'User can log in with correct credsentials' do
    sign_up
    sign_in
    expect(current_path).to eq('/home')
    expect(page).to have_content('Welcome to Chitter, jinis!')
  end

  scenario 'User can\'t log in with incorrect password' do
    sign_up
    sign_in(password: 'wrong')
    expect(current_path).to eq('/sessions')
    expect(page).to have_content('incorrect email or password')
  end
end
