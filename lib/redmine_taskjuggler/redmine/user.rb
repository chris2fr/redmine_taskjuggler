#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    class User
      attr_accessor :login,
        :firstname,
        :lastname,
        :mail,
        :team
    end
  end
end
