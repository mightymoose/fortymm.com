defmodule FortymmWeb.ScoringProposalVerificationLive.NewTest do
  use FortymmWeb.ConnCase, async: true

  import Fortymm.MatchesFixtures
  import Fortymm.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Fortymm.Matches.ScoringProposal
  alias Fortymm.Matches.Match
  alias Fortymm.Matches

  test "redirects to the log in page if no user is logged in", %{conn: conn} do
    assert conn
           |> get("/matches/1/games/1/scores/1/verification/new")
           |> redirected_to() == "/users/log_in"
  end

  test "redirects to the match page if the game does not belong to the match", %{conn: conn} do
    user = user_fixture()
    challenge = challenge_fixture()

    {:ok, %{match: match}} =
      Matches.create_match_from_challenge(challenge, user)

    assert conn
           |> log_in_user(user)
           |> get("/matches/#{match.id}/games/0/scores/1/verification/new")
           |> redirected_to() == "/matches/#{match.id}"
  end

  test "redirects to the match page if the scoring proposal does not belong to the game", %{
    conn: conn
  } do
    user = user_fixture()
    challenge = challenge_fixture()

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    assert conn
           |> log_in_user(user)
           |> get("/matches/#{match.id}/games/#{first_game.id}/scores/0/verification/new")
           |> redirected_to() == "/matches/#{match.id}"
  end

  test "redirects to the match page if the user is not a match participant", %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture()

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: other_user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    assert conn
           |> log_in_user(other_user)
           |> get(
             "/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new"
           )
           |> redirected_to() == "/matches/#{match.id}"
  end

  test "redirects to the most recent scoring proposal if this one has been rejected and there is a new one for this game",
       %{conn: conn} do
    user = user_fixture()
    challenge = challenge_fixture()

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    Matches.create_scoring_proposal_resolution(%{
      scoring_proposal_id: score.id,
      created_by_id: user.id,
      accepted: false
    })

    {:ok, new_score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    assert conn
           |> log_in_user(user)
           |> get(
             "/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new"
           )
           |> redirected_to() ==
             "/matches/#{match.id}/games/#{first_game.id}/scores/#{new_score.id}/verification/new"
  end

  test "redirects to the scoring proposal page if this one has been rejected and there is no new one for this game",
       %{conn: conn} do
    user = user_fixture()
    challenge = challenge_fixture()

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    Matches.create_scoring_proposal_resolution(%{
      scoring_proposal_id: score.id,
      created_by_id: user.id,
      accepted: false
    })

    assert conn
           |> log_in_user(user)
           |> get(
             "/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new"
           )
           |> redirected_to() ==
             "/matches/#{match.id}/games/#{first_game.id}/scores/new"
  end

  test "redirects to the new game page if there is an accepted scoring proposal and an in progress game",
       %{conn: conn} do
    user = user_fixture()
    challenge = challenge_fixture(%{maximum_number_of_games: 3})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    Matches.create_scoring_proposal_resolution(%{
      scoring_proposal_id: score.id,
      created_by_id: user.id,
      accepted: true
    })

    {:match_not_completed, new_game} = Matches.complete_game(first_game.id)

    assert conn
           |> log_in_user(user)
           |> get(
             "/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new"
           )
           |> redirected_to() ==
             "/matches/#{match.id}/games/#{new_game.id}/scores/new"
  end

  test "redirects to the match page if the match has ended", %{conn: conn} do
    user = user_fixture()
    challenge = challenge_fixture(%{maximum_number_of_games: 1})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    Matches.create_scoring_proposal_resolution(%{
      scoring_proposal_id: score.id,
      created_by_id: user.id,
      accepted: true
    })

    assert conn
           |> log_in_user(user)
           |> get("/matches/#{match.id}/games/1/scores/1/verification/new")
           |> redirected_to() == "/matches/#{match.id}"
  end

  test "renders the scoring proposal verification form for the user who did not create the scoring proposal",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, _lv, html} =
      conn
      |> log_in_user(other_user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    assert html =~ "According to #{user.username} you lost the game 1 to 11"
  end

  test "renders a waiting message for the user who created the scoring proposal", %{conn: conn} do
    user = user_fixture()
    challenge = challenge_fixture()

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, _lv, html} =
      conn
      |> log_in_user(user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    assert html =~ "Waiting for your opponent to accept the score"
  end

  test "creates a scoring proposal resolution when the score is accepted", %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, lv, _html} =
      conn
      |> log_in_user(other_user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    lv
    |> form("#accept-form")
    |> render_submit()

    score = ScoringProposal.load_scoring_proposal_resolution(score)

    assert score.scoring_proposal_resolution.accepted
  end

  test "creates a scoring proposal resolution when the score is rejected", %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, lv, _html} =
      conn
      |> log_in_user(other_user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    lv
    |> form("#reject-form")
    |> render_submit()

    score = ScoringProposal.load_scoring_proposal_resolution(score)

    refute score.scoring_proposal_resolution.accepted
  end

  test "redirects the user who created the scoring proposal to the scoring proposal page if the score is rejected",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, lv, _html} =
      conn
      |> log_in_user(other_user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    redirect_result = "/matches/#{match.id}/games/#{first_game.id}/scores/new"

    assert {:error, {:redirect, %{to: ^redirect_result}}} =
             lv
             |> form("#reject-form")
             |> render_submit()
  end

  test "redirects the user who created the scoring proposal to the next game's scoring page if the score is accepted",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id, maximum_number_of_games: 3})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, other_lv, _html} =
      conn
      |> log_in_user(other_user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    {:ok, lv, _html} =
      conn
      |> log_in_user(user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    other_lv
    |> form("#accept-form")
    |> render_submit()

    %{games: games} = Match.load_games(match)
    next_game = Enum.max_by(games, & &1.id)

    assert_redirect(lv, ~p"/matches/#{match.id}/games/#{next_game.id}/scores/new")
  end

  test "redirects the user who did not create the scoring proposal to the next game's scoring page if the score is accepted",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id, maximum_number_of_games: 3})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: other_user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, lv, _html} =
      conn
      |> log_in_user(user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    lv
    |> form("#accept-form")
    |> render_submit()

    %{games: games} = Match.load_games(match)
    next_game = Enum.max_by(games, & &1.id)

    assert_redirect(lv, ~p"/matches/#{match.id}/games/#{next_game.id}/scores/new")
  end

  test "redirects the user who did not create the scoring proposal to the match page if the score is rejected",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id, maximum_number_of_games: 3})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: other_user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, lv, _html} =
      conn
      |> log_in_user(user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    lv
    |> form("#reject-form")
    |> render_submit()

    assert_redirect(lv, ~p"/matches/#{match.id}/games/#{first_game.id}/scores/new")
  end

  test "redirects the user who created the scoring proposal to the match page if the score is accepted and the match is over",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id, maximum_number_of_games: 1})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, other_lv, _html} =
      conn
      |> log_in_user(other_user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    {:ok, lv, _html} =
      conn
      |> log_in_user(user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    redirect_result = "/matches/#{match.id}"

    other_lv
    |> form("#accept-form")
    |> render_submit()

    assert_redirect(lv, redirect_result)
  end

  test "redirects the user who did not create the scoring proposal to the match page if the score is accepted and the match is over",
       %{conn: conn} do
    user = user_fixture()
    other_user = user_fixture()
    challenge = challenge_fixture(%{created_by_id: other_user.id, maximum_number_of_games: 1})

    {:ok, %{match: match, first_game: first_game}} =
      Matches.create_match_from_challenge(challenge, user)

    match = Match.load_participants(match)
    [first_participant, second_participant] = match.match_participants

    {:ok, score} =
      Matches.create_scoring_proposal(%{
        game_id: first_game.id,
        created_by_id: other_user.id,
        scores: [
          %{
            score: 1,
            match_participant_id: first_participant.id
          },
          %{
            score: 11,
            match_participant_id: second_participant.id
          }
        ]
      })

    {:ok, lv, _html} =
      conn
      |> log_in_user(user)
      |> live("/matches/#{match.id}/games/#{first_game.id}/scores/#{score.id}/verification/new")

    redirect_result = "/matches/#{match.id}"

    assert {:error, {:redirect, %{status: 302, to: ^redirect_result}}} =
             lv
             |> form("#accept-form")
             |> render_submit()
  end
end
