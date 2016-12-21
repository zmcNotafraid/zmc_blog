# -*- encoding : utf-8 -*-
module Refinery
  module Core
    class BaseModel < ActiveRecord::Base

      self.abstract_class = true

    end
  end
end
