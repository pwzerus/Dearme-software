require 'rails_helper'

RSpec.describe UserPostMention, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Liquid")
  }

  it "should allow mentioning multiple users within a post" do
    p = Post.create!(creator: test_user, title: "Some post")

    mention_user_1 = User.create!(
            email: "revolverocelot@bibboss.com",
            first_name: "Revolver",
            last_name: "Ocelot"
            )

    mention_user_2 = User.create!(
            email: "bugsbunny@lola.com",
            first_name: "Bugs",
            last_name: "Bunny"
            )

    p.mentioned_users << mention_user_1
    p.mentioned_users << mention_user_2

    expect(p.mentioned_users).to match_array([ mention_user_1, mention_user_2 ])
    expect(mention_user_1.posts_mentioned_in).to match_array([ p ])
    expect(mention_user_2.posts_mentioned_in).to match_array([ p ])
  end

  it "should allow user to be mentioned in multiple posts" do
     mention_user = User.create!(
             email: "revolverocelot@bibboss.com",
             first_name: "Revolver",
             last_name: "Ocelot"
             )

     p1 = Post.create!(creator: test_user, title: "Post 1")
     p2 = Post.create!(creator: test_user, title: "Post 2")

     mention_user.posts_mentioned_in << p1
     mention_user.posts_mentioned_in << p2

     expect(p1.mentioned_users).to match_array([ mention_user ])
     expect(p2.mentioned_users).to match_array([ mention_user ])
  end

  it "should not allow creator to be mentioned in a post" do
    # Post mentions are meant for user who aren't the post creator
    # but still should be able to view the post. So, creator themselves
    # shouldn't be mentioned there
    p = Post.create!(creator: test_user, title: "Some post")

    expect {
      p.mentioned_users << test_user
    }.to raise_error(ActiveRecord::RecordInvalid)

    expect {
      test_user.posts_mentioned_in << p
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
