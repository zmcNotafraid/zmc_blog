# -*- encoding : utf-8 -*-
require 'spec_helper'

module Refinery
  module Blog
    describe Comment do
      context "wiring up" do
        let(:comment) { FactoryGirl.create(:blog_comment) }

        it "saves" do
          comment.should_not be_nil
        end

        it "has a blog post" do
          comment.post.should_not be_nil
        end
      end
      it 'should not save if contains spam keywords' do
        begin
          comment = FactoryGirl.create(:blog_comment, :body => 'lalala, http://')
        rescue Exception => e
          e.class.should == ActiveRecord::RecordInvalid
        end
      end
    end
  end
end
