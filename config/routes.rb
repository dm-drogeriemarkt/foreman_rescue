# frozen_string_literal: true

Rails.application.routes.draw do
  constraints(:id => /[^\/]+/) do
    resources :hosts, controller: 'foreman_rescue/hosts', :only => [] do
      member do
        get 'rescue'
        put 'set_rescue'
        put 'cancel_rescue'
      end
    end
  end
end
