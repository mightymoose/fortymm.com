class Match < ApplicationRecord
    VALID_MATCH_LENGTHS = [ 1, 3, 5, 7 ]

    enum :status, [ :pending, :waiting_for_players, :in_progress, :stopped, :cancelled, :finished ], default: :pending

    validates :maximum_number_of_games, presence: true, inclusion: { in: VALID_MATCH_LENGTHS }
    validates :status, presence: true, inclusion: { in: statuses }

    def self.available_match_lengths
        @available_match_lengths
    end
end
