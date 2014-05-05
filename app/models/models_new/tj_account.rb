# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_account.rb
##
# The Account in TaskJuggler
class TjAccount < ActiveRecord::Base
  unloadable
  ##
  # Sub-Accounts
  has_many :tj_accounts
  ##
  # Identifier of the account
  attr_accessor :code
  ##
  # Name of the account
  attr_accessor :name
  
  def to_hashtable
    result = {
      code: code,
      name: name,
      tj_accounts: {}
    }
    tj_accounts.each { | account |
      result[:tj_accounts] << tj_account.to_hashtable
    }
    result
  end

end