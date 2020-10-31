# frozen_string_literal: true

json.array! @sessions, partial: 'sessions/session', as: :session
