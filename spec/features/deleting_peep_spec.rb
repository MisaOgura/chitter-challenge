feature 'Deleting a peep:' do

  scenario 'User who posted a chitter can delete it' do
    sign_up
    log_in
    post_peep
    expect(page).to have_content('Test post')
    expect(page).to have_xpath('//input[@type="hidden"][@name="delete_id"]')
    expect{ delete_peep }.to change(Post, :count).by(-1)
    expect(page).not_to have_content('Test post')
  end
end
