# Design Principles Analysis Report

## Pull Request Information

| Property | Value |
|----------|-------|
| **Repository** | expertiza/expertiza |
| **PR Number** | #2933 |
| **Title** | E2500 refactor student teams functionality |
| **Author** | sweekar52 |
| **URL** | [https://github.com/expertiza/expertiza/pull/2933](https://github.com/expertiza/expertiza/pull/2933) |
| **State** | open |
| **Merged** | No |

## Summary

| Metric | Count |
|--------|-------|
| Files Analyzed | 97 |
| Files with Violations | 43 |
| Total Violations | 149 |
| Violations in Changed Code | 149 |
| High Severity Violations | 144 |

### Violations by Design Principle

| Principle | Count |
|-----------|-------|
| Information Expert | 95 |
| Law of Demeter | 30 |
| Single Responsibility Principle | 7 |
| Encapsulation | 6 |
| Dependency Inversion Principle | 4 |
| Open/Closed Principle | 1 |
| Overuse of Class Methods | 6 |

## Detailed Findings

### app/controllers/assessment360_controller.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Information Expert

- **Class/Module:** `Assessment360Controller`
- **Line:** 131
- **Confidence:** 75%
- **Reason:** Method `assignment_grade_summary` manipulates external state 6 times vs 5 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def assignment_grade_summary(cp, assignment_id, penalties)
    user_id = cp.user_id
    # topic exists if a team signed up for a topic, which can be found via the user and the assignment
    topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
    @topics[cp.id][assignment_id] = SignUpTopic.find_by(id: topic_id)
    # instructor grade is stored in the team model, which is found by finding the user's team for the assignment
```

#### 2. Information Expert

- **Class/Module:** `Assessment360Controller`
- **Line:** 145
- **Confidence:** 80%
- **Reason:** Method `insure_existence_of` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def insure_existence_of(course_participants, course)
    if course_participants.empty?
      flash[:error] = "There is no course participant in course #{course.name}"
      redirect_back fallback_location: root_path
    end
  end
```

### app/controllers/grades_controller.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Law of Demeter

- **Class/Module:** `GradesController`
- **Line:** 58
- **Confidence:** 80%
- **Reason:** Method `view_my_scores` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def view_my_scores
    @participant = AssignmentParticipant.find(params[:id])
    @team_id = TeamsParticipant.team_id(@participant.parent_id, @participant.user_id)
    return if redirect_when_disallowed

    @assignment = @participant.assignment
```

### app/controllers/invitations_controller.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Information Expert

- **Class/Module:** `InvitationsController`
- **Line:** 141
- **Confidence:** 75%
- **Reason:** Method `check_team_before_accept` manipulates external state 4 times vs 3 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def check_team_before_accept
    @inv = Invitation.find(params[:inv_id])
    # check if the inviter's team is still existing, and have available slot to add the invitee
    inviter_assignment_team = AssignmentTeam.team(AssignmentParticipant.find_by(user_id: @inv.from_id, parent_id: @inv.assignment_id))
    if inviter_assignment_team.nil?
      flash[:error] = 'The team that invited you does not exist anymore.'
```

### app/controllers/join_team_requests_controller.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Information Expert

- **Class/Module:** `JoinTeamRequestsController`
- **Line:** 90
- **Confidence:** 80%
- **Reason:** Method `check_team_status` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def check_team_status
    # check if the advertisement is from a team member and if so disallow requesting invitations
    team_member = TeamsParticipant.where(['team_id =? and user_id =?', params[:team_id], session[:user][:id]])
    team = Team.find(params[:team_id])
    return flash[:error] = 'This team is full.' if team.full?
    return flash[:error] = 'You are already a member of this team.' unless team_member.empty?
```

#### 2. Information Expert

- **Class/Module:** `JoinTeamRequestsController`
- **Line:** 102
- **Confidence:** 80%
- **Reason:** Method `respond_after` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def respond_after(request)
    respond_to do |format|
      format.html
      format.xml { render xml: request }
    end
  end
```

### app/controllers/lottery_controller.rb

**Status:** modified
**Changes:** +3 / -3

#### 1. Information Expert

- **Class/Module:** `LotteryController`
- **Line:** 85
- **Confidence:** 95%
- **Reason:** Method `create_new_teams_for_bidding_response` manipulates external state 8 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def create_new_teams_for_bidding_response(teams, assignment, users_bidding_info)
    teams.each do |user_ids|
      if assignment.auto_assign_mentor
        new_team = MentoredTeam.create_team_with_users(assignment.id, user_ids)
      else
        new_team = AssignmentTeam.create_team_with_users(assignment.id, user_ids)
```

### app/controllers/pair_programming_controller.rb

**Status:** modified
**Changes:** +4 / -4

#### 1. Single Responsibility Principle

- **Class/Module:** `PairProgrammingController`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class exposes 4 methods (limit: 4).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class PairProgrammingController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_student_privileges?
  end

  def send_invitations
```

#### 2. Information Expert

- **Class/Module:** `PairProgrammingController`
- **Line:** 8
- **Confidence:** 85%
- **Reason:** Method `send_invitations` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def send_invitations
    users = TeamsParticipant.where(team_id: params[:team_id])
    users.each { |user| user.update_attributes(pair_programming_status: "W") }
    TeamsParticipant.find_by(team_id: params[:team_id], user_id: current_user.id).update_attributes(pair_programming_status: "A")
    # ExpertizaLogger.info "Accepting Invitation #{params[:inv_id]}: #{accepted}"
    Team.find(params[:team_id]).update_attributes(pair_programming_request: 1)
```

#### 3. Information Expert

- **Class/Module:** `PairProgrammingController`
- **Line:** 18
- **Confidence:** 80%
- **Reason:** Method `accept` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def accept
    user = TeamsParticipant.find_by(team_id: params[:team_id], user_id: current_user.id)
    user.update_attributes(pair_programming_status: "A")
    flash[:success] = "Pair Programming Request Accepted Successfully!"
    redirect_to view_student_teams_path student_id: params[:student_id]
  end
```

#### 4. Information Expert

- **Class/Module:** `PairProgrammingController`
- **Line:** 25
- **Confidence:** 80%
- **Reason:** Method `decline` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def decline
    user = TeamsParticipant.find_by(team_id: params[:team_id], user_id: current_user.id)
    user.update_attributes(pair_programming_status: "D")
    Team.find(params[:team_id]).update_attributes(pair_programming_request: 0)
    flash[:success] = "Pair Programming Request Declined!"
    redirect_to view_student_teams_path student_id: params[:student_id]
```

#### 5. Encapsulation

- **Class/Module:** `PairProgrammingController`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Has 100.0% public methods (limit: 60.0%).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class PairProgrammingController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_student_privileges?
  end

  def send_invitations
```

### app/controllers/participants_controller.rb

**Status:** modified
**Changes:** +5 / -5

#### 1. Law of Demeter

- **Class/Module:** `ParticipantsController`
- **Line:** 205
- **Confidence:** 80%
- **Reason:** Method `get_user_info` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_user_info(team_participant, assignment)
    user = {}
    user[:name] = team_participant.name
    user[:fullname] = team_participant.fullname
    # set by default
    permission_granted = false
```

#### 2. Law of Demeter

- **Class/Module:** `ParticipantsController`
- **Line:** 221
- **Confidence:** 80%
- **Reason:** Method `get_signup_topics_for_assignment` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_signup_topics_for_assignment(assignment_id, team_info, team_id)
    signup_topics = SignUpTopic.where('assignment_id = ?', assignment_id)
    if signup_topics.any?
      has_topics = true
      signup_topics.each do |signup_topic|
        signup_topic.signed_up_teams.each do |signed_up_team|
```

#### 3. Information Expert

- **Class/Module:** `ParticipantsController`
- **Line:** 205
- **Confidence:** 95%
- **Reason:** Method `get_user_info` manipulates external state 6 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_user_info(team_participant, assignment)
    user = {}
    user[:name] = team_participant.name
    user[:fullname] = team_participant.fullname
    # set by default
    permission_granted = false
```

#### 4. Information Expert

- **Class/Module:** `ParticipantsController`
- **Line:** 221
- **Confidence:** 95%
- **Reason:** Method `get_signup_topics_for_assignment` manipulates external state 6 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_signup_topics_for_assignment(assignment_id, team_info, team_id)
    signup_topics = SignUpTopic.where('assignment_id = ?', assignment_id)
    if signup_topics.any?
      has_topics = true
      signup_topics.each do |signup_topic|
        signup_topic.signed_up_teams.each do |signed_up_team|
```

### app/controllers/popup_controller.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Information Expert

- **Class/Module:** `PopupController`
- **Line:** 35
- **Confidence:** 85%
- **Reason:** Method `team_participants_popup` manipulates external state 25 times vs 22 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def team_participants_popup
    @ip = session[:ip]
    @sum = 0
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @team_participants = TeamsParticipant.where(team_id: params[:id])
```

### app/controllers/review_mapping_controller.rb

**Status:** modified
**Changes:** +10 / -10

#### 1. Law of Demeter

- **Class/Module:** `ReviewMappingController`
- **Line:** 344
- **Confidence:** 80%
- **Reason:** Method `automatic_review_mapping` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def automatic_review_mapping
    assignment_id = params[:id].to_i
    assignment = Assignment.find(params[:id])
    participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
    teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
```

#### 2. Law of Demeter

- **Class/Module:** `ReviewMappingController`
- **Line:** 515
- **Confidence:** 80%
- **Reason:** Method `peer_review_strategy` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def peer_review_strategy(assignment_id, review_strategy, participants_hash)
    teams = review_strategy.teams
    participants = review_strategy.participants
    num_participants = participants.size

    teams.each_with_index do |team, iterator|
```

#### 3. Information Expert

- **Class/Module:** `ReviewMappingController`
- **Line:** 54
- **Confidence:** 95%
- **Reason:** Method `add_reviewer` manipulates external state 12 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def add_reviewer
    assignment = Assignment.find(params[:id])
    topic_id = params[:topic_id]
    user_id = User.where(name: params[:user][:name]).first.id
    # If instructor want to assign one student to review his/her own artifact,
    # it should be counted as "self-review" and we need to make /app/views/submitted_content/_selfreview.html.erb work.
```

#### 4. Information Expert

- **Class/Module:** `ReviewMappingController`
- **Line:** 344
- **Confidence:** 95%
- **Reason:** Method `automatic_review_mapping` manipulates external state 20 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def automatic_review_mapping
    assignment_id = params[:id].to_i
    assignment = Assignment.find(params[:id])
    participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
    teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
```

#### 5. Information Expert

- **Class/Module:** `ReviewMappingController`
- **Line:** 515
- **Confidence:** 95%
- **Reason:** Method `peer_review_strategy` manipulates external state 40 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def peer_review_strategy(assignment_id, review_strategy, participants_hash)
    teams = review_strategy.teams
    participants = review_strategy.participants
    num_participants = participants.size

    teams.each_with_index do |team, iterator|
```

### app/controllers/sign_up_sheet_controller.rb

**Status:** modified
**Changes:** +6 / -6

#### 1. Law of Demeter

- **Class/Module:** `SignUpSheetController`
- **Line:** 290
- **Confidence:** 80%
- **Reason:** Method `delete_signup_as_instructor` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete_signup_as_instructor
    # find participant using assignment using team and topic ids
    team = Team.find(params[:id])
    assignment = Assignment.find(team.parent_id)
    user = TeamsParticipant.find_by(team_id: team.id).user
    participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id)
```

#### 2. Information Expert

- **Class/Module:** `SignUpSheetController`
- **Line:** 290
- **Confidence:** 95%
- **Reason:** Method `delete_signup_as_instructor` manipulates external state 13 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete_signup_as_instructor
    # find participant using assignment using team and topic ids
    team = Team.find(params[:id])
    assignment = Assignment.find(team.parent_id)
    user = TeamsParticipant.find_by(team_id: team.id).user
    participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id)
```

#### 3. Information Expert

- **Class/Module:** `SignUpSheetController`
- **Line:** 424
- **Confidence:** 95%
- **Reason:** Method `switch_original_topic_to_approved_suggested_topic` manipulates external state 7 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def switch_original_topic_to_approved_suggested_topic
    assignment = AssignmentParticipant.find(params[:id]).assignment
    team_id = TeamsParticipant.team_id(assignment.id, session[:user].id)

    # Tmp variable to store topic id before change
    original_topic_id = SignedUpTeam.topic_id(assignment.id.to_i, session[:user].id)
```

### app/controllers/student_teams_controller.rb

**Status:** modified
**Changes:** +8 / -8

#### 1. Information Expert

- **Class/Module:** `StudentTeamsController`
- **Line:** 122
- **Confidence:** 95%
- **Reason:** Method `remove_participant` manipulates external state 8 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def remove_participant
    # remove the record from teams_participants table
    team_participant = TeamsParticipant.where(team_id: params[:team_id], user_id: student.user_id)
    remove_team_participant(team_participant)
    # if your old team does not have any members, delete the entry for the team
    if TeamsParticipant.where(team_id: params[:team_id]).empty?
```

#### 2. Information Expert

- **Class/Module:** `StudentTeamsController`
- **Line:** 143
- **Confidence:** 80%
- **Reason:** Method `remove_team_participant` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def remove_team_participant(team_participant)
    return false unless team_participant

    team_participant.destroy_all
    undo_link "The user \"#{team_participant.name}\" has been successfully removed from the team."
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'User removed a participant from the team', request)
```

#### 3. Information Expert

- **Class/Module:** `StudentTeamsController`
- **Line:** 151
- **Confidence:** 80%
- **Reason:** Method `team_created_successfully` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def team_created_successfully(current_team = nil)
    if current_team
      undo_link "The team \"#{current_team.name}\" has been successfully updated."
    else
      undo_link "The team \"#{team.name}\" has been successfully updated."
    end
```

### app/controllers/suggestion_controller.rb

**Status:** modified
**Changes:** +4 / -4

#### 1. Information Expert

- **Class/Module:** `SuggestionController`
- **Line:** 94
- **Confidence:** 90%
- **Reason:** Method `send_email` manipulates external state 8 times vs 4 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def send_email
    proposer = User.find_by(id: @user_id)
    if proposer
      teams_participants = TeamsParticipant.where(team_id: @team_id)
      cc_mail_list = []
      teams_participants.each do |teams_participant|
```

### app/controllers/teams_controller.rb

**Status:** modified
**Changes:** +4 / -4

#### 1. Law of Demeter

- **Class/Module:** `TeamsController`
- **Line:** 115
- **Confidence:** 80%
- **Reason:** Method `delete_all` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete_all
    root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
    child_nodes = root_node.get_teams.map(&:node_object_id)
    Team.destroy_all if child_nodes
    redirect_to action: 'list', id: params[:id]
  end
```

#### 2. Law of Demeter

- **Class/Module:** `TeamsController`
- **Line:** 123
- **Confidence:** 80%
- **Reason:** Method `delete` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete
    # delete records in team, teams_participants, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      # Find all SignedUpTeam records associated with the found team.
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
```

### app/controllers/teams_participants_controller.rb

**Status:** added
**Changes:** +71 / -0

#### 1. Single Responsibility Principle

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class exposes 8 methods (limit: 4).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamsParticipantsController < ApplicationController
  before_action :set_team,   only: %i[index new create delete_selected]
  before_action :set_member, only: %i[destroy]

  # GET /teams/:team_id/teams_participants
  def index
    @assignment         = @team.parent
    @teams_participants = @team.teams_participants.includes(participant: :user)
```

#### 2. Dependency Inversion Principle

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Directly instantiates 1 concrete collaborators; prefer dependency injection.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamsParticipantsController < ApplicationController
  before_action :set_team,   only: %i[index new create delete_selected]
  before_action :set_member, only: %i[destroy]

  # GET /teams/:team_id/teams_participants
  def index
    @assignment         = @team.parent
    @teams_participants = @team.teams_participants.includes(participant: :user)
```

#### 3. Law of Demeter

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 6
- **Confidence:** 80%
- **Reason:** Method `index` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def index
    @assignment         = @team.parent
    @teams_participants = @team.teams_participants.includes(participant: :user)
  end
```

#### 4. Law of Demeter

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 17
- **Confidence:** 90%
- **Reason:** Method `create` contains a call chain of length 4.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def create
    user = User.find_by(name: join_params[:user_name])
    unless user
      flash.now[:error] = "No user found with name #{join_params[:user_name].inspect}"
      return render :new, status: :unprocessable_entity
    end
```

#### 5. Information Expert

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 17
- **Confidence:** 95%
- **Reason:** Method `create` manipulates external state 11 times vs 4 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def create
    user = User.find_by(name: join_params[:user_name])
    unless user
      flash.now[:error] = "No user found with name #{join_params[:user_name].inspect}"
      return render :new, status: :unprocessable_entity
    end
```

#### 6. Information Expert

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 51
- **Confidence:** 75%
- **Reason:** Method `delete_selected` manipulates external state 3 times vs 2 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete_selected
    ids     = Array(params[:selected]).map(&:to_i).uniq
    deleted = TeamsParticipant.where(id: ids, team_id: @team.id).destroy_all
    flash[:notice] = "Removed #{deleted.size} #{'member'.pluralize(deleted.size)}."
    redirect_to team_teams_participants_path(@team)
  end
```

#### 7. Encapsulation

- **Class/Module:** `TeamsParticipantsController`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Has 100.0% public methods (limit: 60.0%).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamsParticipantsController < ApplicationController
  before_action :set_team,   only: %i[index new create delete_selected]
  before_action :set_member, only: %i[destroy]

  # GET /teams/:team_id/teams_participants
  def index
    @assignment         = @team.parent
    @teams_participants = @team.teams_participants.includes(participant: :user)
```

### app/controllers/teams_users_controller.rb

**Status:** removed
**Changes:** +0 / -112

> No design principle violations detected.

### app/controllers/users_controller.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### app/helpers/assignment_helper.rb

**Status:** modified
**Changes:** +3 / -3

#### 1. Information Expert

- **Class/Module:** `AssignmentHelper`
- **Line:** 78
- **Confidence:** 95%
- **Reason:** Method `get_data_for_list_submissions` manipulates external state 9 times vs 1 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_data_for_list_submissions(team)
    teams_participants = TeamsParticipant.where(team_id: team.id)
    topic = SignedUpTeam.where(team_id: team.id).first.try :topic
    topic_identifier = topic.try :topic_identifier
    topic_name = topic.try :topic_name
    users_for_curr_team = []
```

#### 2. Information Expert

- **Class/Module:** `AssignmentHelper`
- **Line:** 95
- **Confidence:** 80%
- **Reason:** Method `get_team_name_color_in_list_submission` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_team_name_color_in_list_submission(team)
    if team.try(:grade_for_submission) && team.try(:comment_for_submission)
      '#cd6133' # brown. submission grade has been assigned.
    else
      '#0984e3' # submission grade is not assigned yet.
    end
```

### app/helpers/manage_team_helper.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Dependency Inversion Principle

- **Class/Module:** `ManageTeamHelper`
- **Line:** 4
- **Confidence:** 95%
- **Reason:** Directly instantiates 1 concrete collaborators; prefer dependency injection.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
module ManageTeamHelper
  # Adds a user specified by 'user' object to a team specified by 'team_id'
  def create_team_participants(user, team_id)
    # if user does not exist flash message
    unless user
      urlCreate = url_for controller: 'users', action: 'new'
      ExpertizaLogger.error LoggerMessage.new('ManageTeamHelper', '', 'User being added to the team does not exist!', request)
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
```

#### 2. Information Expert

- **Class/Module:** `ManageTeamHelper`
- **Line:** 6
- **Confidence:** 80%
- **Reason:** Method `create_team_participants` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def create_team_participants(user, team_id)
    # if user does not exist flash message
    unless user
      urlCreate = url_for controller: 'users', action: 'new'
      ExpertizaLogger.error LoggerMessage.new('ManageTeamHelper', '', 'User being added to the team does not exist!', request)
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
```

### app/helpers/review_mapping_helper.rb

**Status:** modified
**Changes:** +3 / -3

#### 1. Law of Demeter

- **Class/Module:** `ReviewMappingHelper`
- **Line:** 116
- **Confidence:** 80%
- **Reason:** Method `get_team_reviewed_link_name` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_team_reviewed_link_name(max_team_size, _response, reviewee_id, ip_address)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsParticipant.where(team_id: reviewee_id).first.user.fullname(ip_address)
                              else
                                # E1991 : check anonymized view here
                                Team.find(reviewee_id).name
```

#### 2. Information Expert

- **Class/Module:** `ReviewMappingHelper`
- **Line:** 109
- **Confidence:** 80%
- **Reason:** Method `link_updated_since_last?` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def link_updated_since_last?(round, due_dates, link_updated_at)
    submission_due_date = due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission_due_last_round = due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
    (link_updated_at < submission_due_date) && (link_updated_at > submission_due_last_round)
  end
```

#### 3. Information Expert

- **Class/Module:** `ReviewMappingHelper`
- **Line:** 116
- **Confidence:** 85%
- **Reason:** Method `get_team_reviewed_link_name` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_team_reviewed_link_name(max_team_size, _response, reviewee_id, ip_address)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsParticipant.where(team_id: reviewee_id).first.user.fullname(ip_address)
                              else
                                # E1991 : check anonymized view here
                                Team.find(reviewee_id).name
```

#### 4. Information Expert

- **Class/Module:** `ReviewMappingHelper`
- **Line:** 402
- **Confidence:** 85%
- **Reason:** Method `get_css_style_for_calibration_report` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_css_style_for_calibration_report(diff)
    # diff - difference between stu's answer and instructor's answer
    dict = { 0 => 'c5', 1 => 'c4', 2 => 'c3', 3 => 'c2' }
    css_class = if dict.key?(diff.abs)
                  dict[diff.abs]
                else
```

### app/helpers/sign_up_sheet_helper.rb

**Status:** modified
**Changes:** +7 / -7

#### 1. Law of Demeter

- **Class/Module:** `SignUpSheetHelper`
- **Line:** 33
- **Confidence:** 80%
- **Reason:** Method `get_intelligent_topic_row` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_intelligent_topic_row(topic, selected_topics, max_team_size = 3)
    row_html = ''
    if selected_topics.present?
      selected_topics.each do |selected_topic|
        row_html = if (selected_topic.topic_id == topic.id) && !selected_topic.is_waitlisted
                     '<tr bgcolor="yellow">'
```

#### 2. Law of Demeter

- **Class/Module:** `SignUpSheetHelper`
- **Line:** 59
- **Confidence:** 90%
- **Reason:** Method `render_participant_info` contains a call chain of length 4.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def render_participant_info(topic, assignment, participants)
    html = ''
    if participants.present?
      chooser_present = false
      participants.each do |participant|
        next unless topic.id == participant.topic_id
```

#### 3. Information Expert

- **Class/Module:** `SignUpSheetHelper`
- **Line:** 22
- **Confidence:** 75%
- **Reason:** Method `get_suggested_topics` manipulates external state 2 times vs 1 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_suggested_topics(assignment_id)
    team_id = TeamsParticipant.team_id(assignment_id, session[:user].id)
    teams_participants = TeamsParticipant.where(team_id: team_id)
    teams_participants_array = []
    teams_participants.each do |teams_participant|
      teams_participants_array << teams_participant.user_id
```

#### 4. Information Expert

- **Class/Module:** `SignUpSheetHelper`
- **Line:** 33
- **Confidence:** 95%
- **Reason:** Method `get_intelligent_topic_row` manipulates external state 11 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_intelligent_topic_row(topic, selected_topics, max_team_size = 3)
    row_html = ''
    if selected_topics.present?
      selected_topics.each do |selected_topic|
        row_html = if (selected_topic.topic_id == topic.id) && !selected_topic.is_waitlisted
                     '<tr bgcolor="yellow">'
```

#### 5. Information Expert

- **Class/Module:** `SignUpSheetHelper`
- **Line:** 59
- **Confidence:** 95%
- **Reason:** Method `render_participant_info` manipulates external state 15 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def render_participant_info(topic, assignment, participants)
    html = ''
    if participants.present?
      chooser_present = false
      participants.each do |participant|
        next unless topic.id == participant.topic_id
```

### app/helpers/teams_participants_helper.rb

**Status:** added
**Changes:** +2 / -0

> No design principle violations detected.

### app/helpers/teams_users_helper.rb

**Status:** removed
**Changes:** +0 / -2

> No design principle violations detected.

### app/mailers/mail_worker.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Law of Demeter

- **Class/Module:** `MailWorker`
- **Line:** 61
- **Confidence:** 80%
- **Reason:** Method `find_participant_emails` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def find_participant_emails
    emails = []
    participants = Participant.where(parent_id: assignment_id)
    participants.each do |participant|
      emails << participant.user.email unless participant.user.nil?
    end
```

#### 2. Law of Demeter

- **Class/Module:** `MailWorker`
- **Line:** 70
- **Confidence:** 80%
- **Reason:** Method `drop_one_member_topics` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def drop_one_member_topics
    teams = TeamsParticipant.all.group(:team_id).count(:team_id)
    teams.keys.each do |team_id|
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop # check if the one-person-team has signed up a topic
```

#### 3. Law of Demeter

- **Class/Module:** `MailWorker`
- **Line:** 80
- **Confidence:** 80%
- **Reason:** Method `drop_outstanding_reviews` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: assignment_id)
    reviews.each do |review|
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
```

#### 4. Information Expert

- **Class/Module:** `MailWorker`
- **Line:** 61
- **Confidence:** 85%
- **Reason:** Method `find_participant_emails` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def find_participant_emails
    emails = []
    participants = Participant.where(parent_id: assignment_id)
    participants.each do |participant|
      emails << participant.user.email unless participant.user.nil?
    end
```

#### 5. Information Expert

- **Class/Module:** `MailWorker`
- **Line:** 70
- **Confidence:** 85%
- **Reason:** Method `drop_one_member_topics` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def drop_one_member_topics
    teams = TeamsParticipant.all.group(:team_id).count(:team_id)
    teams.keys.each do |team_id|
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop # check if the one-person-team has signed up a topic
```

#### 6. Information Expert

- **Class/Module:** `MailWorker`
- **Line:** 80
- **Confidence:** 95%
- **Reason:** Method `drop_outstanding_reviews` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: assignment_id)
    reviews.each do |review|
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
```

### app/models/assignment.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Law of Demeter

- **Class/Module:** `Assignment`
- **Line:** 102
- **Confidence:** 80%
- **Reason:** Method `remove_empty_teams` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def remove_empty_teams
    empty_teams = teams.reload.select { |team| team.teams_participants.empty? }
    teams.delete(empty_teams)
  end
```

#### 2. Information Expert

- **Class/Module:** `Assignment`
- **Line:** 102
- **Confidence:** 85%
- **Reason:** Method `remove_empty_teams` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def remove_empty_teams
    empty_teams = teams.reload.select { |team| team.teams_participants.empty? }
    teams.delete(empty_teams)
  end
```

#### 3. Information Expert

- **Class/Module:** `Assignment`
- **Line:** 108
- **Confidence:** 85%
- **Reason:** Method `valid_num_review` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def valid_num_review
    self.num_reviews = num_reviews_allowed
    if num_reviews_greater?(num_reviews_required, num_reviews_allowed)
      errors.add(:message, 'Num of reviews required cannot be greater than number of reviews allowed')
    elsif num_reviews_greater?(num_metareviews_required, num_metareviews_allowed)
      errors.add(:message, 'Number of Meta-Reviews required cannot be greater than number of meta-reviews allowed')
```

### app/models/assignment_participant.rb

**Status:** modified
**Changes:** +5 / -5

#### 1. Law of Demeter

- **Class/Module:** `AssignmentParticipant`
- **Line:** 171
- **Confidence:** 80%
- **Reason:** Method `review_file_path` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def review_file_path(response_map_id = nil, participant = nil)
    if response_map_id.nil?
      return if participant.nil?

      no_team_path = assignment.path + '/' + participant.name.parameterize(separator: '_') + '_review'
      return no_team_path if participant.team.nil?
```

#### 2. Information Expert

- **Class/Module:** `AssignmentParticipant`
- **Line:** 171
- **Confidence:** 95%
- **Reason:** Method `review_file_path` manipulates external state 12 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def review_file_path(response_map_id = nil, participant = nil)
    if response_map_id.nil?
      return if participant.nil?

      no_team_path = assignment.path + '/' + participant.name.parameterize(separator: '_') + '_review'
      return no_team_path if participant.team.nil?
```

### app/models/assignment_team.rb

**Status:** modified
**Changes:** +6 / -6

#### 1. Information Expert

- **Class/Module:** `AssignmentTeam`
- **Line:** 212
- **Confidence:** 95%
- **Reason:** Method `team` manipulates external state 8 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.team(participant)
    return nil if participant.nil?

    team = nil
    teams_participants = TeamsParticipant.where(user_id: participant.user_id)
    return nil unless teams_participants
```

#### 2. Information Expert

- **Class/Module:** `AssignmentTeam`
- **Line:** 230
- **Confidence:** 90%
- **Reason:** Method `export_fields` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.export_fields(options)
    fields = []
    fields.push('Team Name')
    fields.push('Team members') if options[:team_name] == 'false'
    fields.push('Assignment Name')
  end
```

#### 3. Information Expert

- **Class/Module:** `AssignmentTeam`
- **Line:** 283
- **Confidence:** 90%
- **Reason:** Method `create_new_team` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def create_new_team(user_id, signuptopic)
    t_user = TeamsParticipant.create(team_id: id, user_id: user_id)
    SignedUpTeam.create(topic_id: signuptopic.id, team_id: id, is_waitlisted: 0)
    parent = TeamNode.create(parent_id: signuptopic.assignment_id, node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
  end
```

### app/models/cake.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Law of Demeter

- **Class/Module:** `Cake`
- **Line:** 116
- **Confidence:** 80%
- **Reason:** Method `calculate_total_score` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def calculate_total_score(question_answers)
    question_score = 0.0
    question_answers.each do |question_answer|
      # calculate score per question
      unless question_answer.answer.nil?
        question_score += question_answer.answer
```

#### 2. Information Expert

- **Class/Module:** `Cake`
- **Line:** 96
- **Confidence:** 90%
- **Reason:** Method `get_total_score_for_question` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_total_score_for_question(review_type, question_id, participant_id, assignment_id, reviewee_id)
    # get the reviewer's team id for the currently answered question
    team_id = Team.joins([:teams_participants, teams_participants: [{ user: :participants }]]).where('participants.id = ? and teams.parent_id in (?)', participant_id, assignment_id).first
    team_id = team_id.id if team_id
    if review_type == 'TeammateReviewResponseMap'
      answers_for_team_members = get_answers_for_teammatereview(team_id, question_id, participant_id, assignment_id, reviewee_id)
```

#### 3. Information Expert

- **Class/Module:** `Cake`
- **Line:** 107
- **Confidence:** 95%
- **Reason:** Method `get_answers_for_teammatereview` manipulates external state 7 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_answers_for_teammatereview(team_id, question_id, participant_id, assignment_id, reviewee_id)
    # get the reviewer's team members for the currently answered question
    team_members = Participant.joins(user: :teams_participants).where('teams_participants.team_id in (?) and participants.parent_id in (?)', team_id, assignment_id).ids
    # get the reviewer's ratings for his team members
    Answer.joins([{ response: :response_map }, :question]).where("response_maps.reviewee_id in (?) and response_maps.reviewed_object_id = (?)
      and answer is not null and response_maps.reviewer_id in (?) and answers.question_id in (?) and response_maps.reviewee_id not in (?)", team_members, assignment_id, participant_id, question_id, reviewee_id).to_a
```

#### 4. Information Expert

- **Class/Module:** `Cake`
- **Line:** 116
- **Confidence:** 85%
- **Reason:** Method `calculate_total_score` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def calculate_total_score(question_answers)
    question_score = 0.0
    question_answers.each do |question_answer|
      # calculate score per question
      unless question_answer.answer.nil?
        question_score += question_answer.answer
```

### app/models/course_team.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Information Expert

- **Class/Module:** `CourseTeam`
- **Line:** 70
- **Confidence:** 90%
- **Reason:** Method `add_member` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def add_member(user, _id = nil)
    raise "The user \"#{user.name}\" is already a member of the team, \"#{name}\"" if user?(user)

    t_user = TeamsParticipant.create(user_id: user.id, team_id: id)
    parent = TeamNode.find_by(node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
```

### app/models/invitation.rb

**Status:** modified
**Changes:** +12 / -12

#### 1. Information Expert

- **Class/Module:** `Invitation`
- **Line:** 20
- **Confidence:** 80%
- **Reason:** Method `remove_users_sent_invites_for_assignment` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.remove_users_sent_invites_for_assignment(user_id, assignment_id)
    invites = Invitation.where('from_id = ? and assignment_id = ?', user_id, assignment_id)
    invites.each(&:destroy)
  end
```

#### 2. Information Expert

- **Class/Module:** `Invitation`
- **Line:** 26
- **Confidence:** 80%
- **Reason:** Method `update_users_topic_after_invite_accept` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.update_users_topic_after_invite_accept(invitee_user_id, invited_user_id, assignment_id)
    new_team_id = TeamsParticipant.team_id(assignment_id, invitee_user_id)
    # check the invited_user_id have ever join other team in this assignment before
    # if so, update the original record; else create a new record
    original_team_id = TeamsParticipant.team_id(assignment_id, invited_user_id)
    if original_team_id
```

#### 3. Information Expert

- **Class/Module:** `Invitation`
- **Line:** 45
- **Confidence:** 75%
- **Reason:** Method `accept_invitation` manipulates external state 2 times vs 1 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.accept_invitation(team_id, inviter_user_id, invited_user_id, assignment_id)
    # if you are on a team and you accept another invitation and if your old team does not have any members, delete the entry for the team
    if TeamsParticipant.team_empty?(team_id) && (team_id != '0')
      assignment_id = AssignmentTeam.find(team_id).assignment.id
      # Release topics for the team has selected by the invited users empty team
      SignedUpTeam.release_topics_selected_by_team_for_assignment(team_id, assignment_id)
```

#### 4. Information Expert

- **Class/Module:** `Invitation`
- **Line:** 68
- **Confidence:** 80%
- **Reason:** Method `is_invited?` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.is_invited?(invitee_user_id, invited_user_id, assignment_id)
    sent_invitation = Invitation.where('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                       invitee_user_id, invited_user_id, assignment_id)
    sent_invitation.empty?
  end
```

### app/models/mentor_management.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Law of Demeter

- **Class/Module:** `MentorManagement`
- **Line:** 43
- **Confidence:** 80%
- **Reason:** Method `assign_mentor` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.assign_mentor(assignment_id, team_id)
    assignment = Assignment.find(assignment_id)
    team = Team.find(team_id)

    # RuboCop 'use guard clause instead of nested conditionals'
    # return if assignments can't accept mentors
```

#### 2. Information Expert

- **Class/Module:** `MentorManagement`
- **Line:** 43
- **Confidence:** 95%
- **Reason:** Method `assign_mentor` manipulates external state 8 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.assign_mentor(assignment_id, team_id)
    assignment = Assignment.find(assignment_id)
    team = Team.find(team_id)

    # RuboCop 'use guard clause instead of nested conditionals'
    # return if assignments can't accept mentors
```

#### 3. Information Expert

- **Class/Module:** `MentorManagement`
- **Line:** 124
- **Confidence:** 95%
- **Reason:** Method `zip_mentors_with_team_count` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.zip_mentors_with_team_count(assignment_id)
    mentor_ids = mentors_for_assignment(assignment_id).pluck(:user_id)
    return [] if mentor_ids.empty?
    team_counts = {}
    mentor_ids.each { |id| team_counts[id] = 0 }
    #E2351 removed (:team_id) after .count to fix balancing algorithm
```

### app/models/mentored_team.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Dependency Inversion Principle

- **Class/Module:** `MentoredTeam`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Directly instantiates 1 concrete collaborators; prefer dependency injection.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class MentoredTeam < AssignmentTeam
    # Class created during refactoring of E2351
    # Overridden method to include the MentorManagement workflow
    def add_member(user, _assignment_id = nil)
        raise "The user #{user.name} is already a member of the team #{name}" if user?(user)
    
        can_add_member = false
        unless full?
```

#### 2. Law of Demeter

- **Class/Module:** `MentoredTeam`
- **Line:** 22
- **Confidence:** 90%
- **Reason:** Method `import_team_members` contains a call chain of length 4.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def import_team_members(row_hash)
        row_hash[:teammembers].each_with_index do |teammate, _index|
          if teammate.to_s.strip.empty?
            next
          end
          user = User.find_by(name: teammate.to_s)
```

#### 3. Information Expert

- **Class/Module:** `MentoredTeam`
- **Line:** 4
- **Confidence:** 95%
- **Reason:** Method `add_member` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def add_member(user, _assignment_id = nil)
        raise "The user #{user.name} is already a member of the team #{name}" if user?(user)
    
        can_add_member = false
        unless full?
          can_add_member = true
```

#### 4. Information Expert

- **Class/Module:** `MentoredTeam`
- **Line:** 22
- **Confidence:** 95%
- **Reason:** Method `import_team_members` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def import_team_members(row_hash)
        row_hash[:teammembers].each_with_index do |teammate, _index|
          if teammate.to_s.strip.empty?
            next
          end
          user = User.find_by(name: teammate.to_s)
```

### app/models/participant.rb

**Status:** modified
**Changes:** +3 / -3

#### 1. Law of Demeter

- **Class/Module:** `Participant`
- **Line:** 58
- **Confidence:** 80%
- **Reason:** Method `force_delete` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def force_delete(maps)
    maps && maps.each(&:destroy)
    if team && (team.teams_participants.length == 1)
      team.delete
    elsif team
      team.teams_participants.each { |teams_participant| teams_participant.destroy if teams_participant.user_id == id }
```

#### 2. Law of Demeter

- **Class/Module:** `Participant`
- **Line:** 68
- **Confidence:** 80%
- **Reason:** Method `topic_name` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def topic_name
    if topic.nil? || topic.topic_name.empty?
      '<center>&#8212;</center>' # em dash
    else
      topic.topic_name
    end
```

#### 3. Information Expert

- **Class/Module:** `Participant`
- **Line:** 50
- **Confidence:** 80%
- **Reason:** Method `delete` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete(force = nil)
    maps = ResponseMap.where('reviewee_id = ? or reviewer_id = ?', id, id)

    raise 'Associations exist for this participant.' unless force || (maps.blank? && team.nil?)

    force_delete(maps)
```

#### 4. Information Expert

- **Class/Module:** `Participant`
- **Line:** 58
- **Confidence:** 95%
- **Reason:** Method `force_delete` manipulates external state 6 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def force_delete(maps)
    maps && maps.each(&:destroy)
    if team && (team.teams_participants.length == 1)
      team.delete
    elsif team
      team.teams_participants.each { |teams_participant| teams_participant.destroy if teams_participant.user_id == id }
```

#### 5. Information Expert

- **Class/Module:** `Participant`
- **Line:** 68
- **Confidence:** 85%
- **Reason:** Method `topic_name` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def topic_name
    if topic.nil? || topic.topic_name.empty?
      '<center>&#8212;</center>' # em dash
    else
      topic.topic_name
    end
```

### app/models/review_response_map.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### app/models/sign_up_sheet.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Single Responsibility Principle

- **Class/Module:** `SignUpSheet`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class exposes 6 methods (limit: 4).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    # Find the team ID for the given assignment and user
    team_id = Team.find_team_participants(assignment_id, user_id)&.first&.t_id
    # If the team doesn't exist, create a new team and assign the team ID
    if team_id.nil?
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
```

#### 2. Information Expert

- **Class/Module:** `SignUpSheet`
- **Line:** 3
- **Confidence:** 80%
- **Reason:** Method `signup_team` manipulates external state 5 times vs 3 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.signup_team(assignment_id, user_id, topic_id = nil)
    # Find the team ID for the given assignment and user
    team_id = Team.find_team_participants(assignment_id, user_id)&.first&.t_id
    # If the team doesn't exist, create a new team and assign the team ID
    if team_id.nil?
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
```

#### 3. Encapsulation

- **Class/Module:** `SignUpSheet`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Has 100.0% public methods (limit: 60.0%).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    # Find the team ID for the given assignment and user
    team_id = Team.find_team_participants(assignment_id, user_id)&.first&.t_id
    # If the team doesn't exist, create a new team and assign the team ID
    if team_id.nil?
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
```

### app/models/sign_up_topic.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Information Expert

- **Class/Module:** `SignUpTopic`
- **Line:** 20
- **Confidence:** 95%
- **Reason:** Method `import` manipulates external state 7 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.import(row_hash, session, _id = nil)
    if row_hash.length < 3
      raise ArgumentError, 'The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional).'
    end

    topic = SignUpTopic.where(topic_name: row_hash[:topic_name], assignment_id: session[:assignment_id]).first
```

### app/models/signed_up_team.rb

**Status:** modified
**Changes:** +6 / -6

#### 1. Law of Demeter

- **Class/Module:** `SignedUpTeam`
- **Line:** 76
- **Confidence:** 80%
- **Reason:** Method `topic_id_by_team_id` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.topic_id_by_team_id(team_id)
    signed_up_teams = SignedUpTeam.where(team_id: team_id, is_waitlisted: 0)
    if signed_up_teams.blank?
      nil
    else
      signed_up_teams.first.topic_id
```

#### 2. Information Expert

- **Class/Module:** `SignedUpTeam`
- **Line:** 9
- **Confidence:** 95%
- **Reason:** Method `find_team_participants` manipulates external state 30 times vs 4 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.find_team_participants(assignment_id, ip_address = nil)
    @participants = SignedUpTeam.joins('INNER JOIN sign_up_topics ON signed_up_teams.topic_id = sign_up_topics.id')
                                .select('signed_up_teams.id as id, sign_up_topics.id as topic_id, sign_up_topics.topic_name as name,
                                  sign_up_topics.topic_name as team_name_placeholder, sign_up_topics.topic_name as user_name_placeholder,
                                  signed_up_teams.is_waitlisted as is_waitlisted, signed_up_teams.team_id as team_id')
                                .where('sign_up_topics.assignment_id = ?', assignment_id)
```

#### 3. Information Expert

- **Class/Module:** `SignedUpTeam`
- **Line:** 41
- **Confidence:** 95%
- **Reason:** Method `find_team_participants` manipulates external state 6 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.find_team_participants(assignment_id, user_id)
    TeamsParticipant.joins('INNER JOIN teams ON teams_participants.team_id = teams.id')
             .select('teams.id as t_id')
             .where('teams.parent_id = ? and teams_participants.user_id = ?', assignment_id, user_id)
  end
```

#### 4. Information Expert

- **Class/Module:** `SignedUpTeam`
- **Line:** 47
- **Confidence:** 95%
- **Reason:** Method `find_user_signup_topics` manipulates external state 9 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.find_user_signup_topics(assignment_id, team_id)
    SignedUpTeam.joins('INNER JOIN sign_up_topics ON signed_up_teams.topic_id = sign_up_topics.id')
                .select('sign_up_topics.id as topic_id, sign_up_topics.topic_name as topic_name, signed_up_teams.is_waitlisted as is_waitlisted,
                  signed_up_teams.preference_priority_number as preference_priority_number')
                .where('sign_up_topics.assignment_id = ? and signed_up_teams.team_id = ?', assignment_id, team_id)
  end
```

#### 5. Information Expert

- **Class/Module:** `SignedUpTeam`
- **Line:** 55
- **Confidence:** 95%
- **Reason:** Method `release_topics_selected_by_team_for_assignment` manipulates external state 9 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.release_topics_selected_by_team_for_assignment(team_id, assignment_id)
    old_teams_signups = SignedUpTeam.where(team_id: team_id)

    # If the team has signed up for the topic and they are on the waitlist then remove that team from the waitlist.
    unless old_teams_signups.nil?
      old_teams_signups.each do |old_teams_signup|
```

#### 6. Information Expert

- **Class/Module:** `SignedUpTeam`
- **Line:** 76
- **Confidence:** 85%
- **Reason:** Method `topic_id_by_team_id` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.topic_id_by_team_id(team_id)
    signed_up_teams = SignedUpTeam.where(team_id: team_id, is_waitlisted: 0)
    if signed_up_teams.blank?
      nil
    else
      signed_up_teams.first.topic_id
```

#### 7. Information Expert

- **Class/Module:** `SignedUpTeam`
- **Line:** 86
- **Confidence:** 85%
- **Reason:** Method `drop_signup_record` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.drop_signup_record(topic_id,team_id)
    # Fetching record for a given topic and team.
    signup_record = SignedUpTeam.find_by(topic_id: topic_id, team_id: team_id)
    # If the signup_record in not nil destroy it.
    signup_record.destroy unless signup_record.nil?
  end
```

### app/models/tag_prompt_deployment.rb

**Status:** modified
**Changes:** +3 / -3

#### 1. Information Expert

- **Class/Module:** `TagPromptDeployment`
- **Line:** 13
- **Confidence:** 95%
- **Reason:** Method `get_number_of_taggable_answers` manipulates external state 10 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def get_number_of_taggable_answers(user_id)
    team = Team.joins(:teams_participants).where(team_participants: { parent_id: assignment_id }, user_id: user_id)
    responses = Response.joins(:response_maps).where(response_maps: { reviewed_object_id: assignment.id, reviewee_id: team.id })
    questions = Question.where(questionnaire_id: questionnaire.id, type: question_type)

    unless responses.empty? || questions.empty?
```

### app/models/team.rb

**Status:** modified
**Changes:** +19 / -19

#### 1. Single Responsibility Principle

- **Class/Module:** `Team`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class exposes 27 methods (limit: 4).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class Team < ApplicationRecord
  has_many :teams_participants, dependent: :destroy
  has_many :users, through: :teams_participants
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail
```

#### 2. Single Responsibility Principle

- **Class/Module:** `Team`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class directly instantiates 2 collaborators.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class Team < ApplicationRecord
  has_many :teams_participants, dependent: :destroy
  has_many :users, through: :teams_participants
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail
```

#### 3. Open/Closed Principle

- **Class/Module:** `Team`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Uses 4 type-checking conditional(s); prefer polymorphism.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class Team < ApplicationRecord
  has_many :teams_participants, dependent: :destroy
  has_many :users, through: :teams_participants
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail
```

#### 4. Dependency Inversion Principle

- **Class/Module:** `Team`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Directly instantiates 2 concrete collaborators; prefer dependency injection.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class Team < ApplicationRecord
  has_many :teams_participants, dependent: :destroy
  has_many :users, through: :teams_participants
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail
```

#### 5. Law of Demeter

- **Class/Module:** `Team`
- **Line:** 128
- **Confidence:** 80%
- **Reason:** Method `randomize_all_by_parent` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.randomize_all_by_parent(parent, team_type, min_team_size)
    participants = Participant.where(parent_id: parent.id, type: parent.class.to_s + 'Participant', can_mentor: [false, nil])
    participants = participants.sort { rand(-1..1) }
    users = participants.map { |p| User.find(p.user_id) }.to_a
    # find teams still need team members and users who are not in any team
    teams = Team.where(parent_id: parent.id, type: parent.class.to_s + 'Team').to_a
```

#### 6. Law of Demeter

- **Class/Module:** `Team`
- **Line:** 150
- **Confidence:** 80%
- **Reason:** Method `create_team_from_single_users` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.create_team_from_single_users(min_team_size, parent, team_type, users)
    num_of_teams = users.length.fdiv(min_team_size).ceil
    next_team_member_index = 0
    (1..num_of_teams).to_a.each do |i|
      team = Object.const_get(team_type + 'Team').create(name: 'Team_' + i.to_s, parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: team.id)
```

#### 7. Law of Demeter

- **Class/Module:** `Team`
- **Line:** 182
- **Confidence:** 80%
- **Reason:** Method `generate_team_name` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.generate_team_name(_team_name_prefix = '')
    last_team = Team.where('name LIKE ?', "#{_team_name_prefix} Team_%")
                  .order("CAST(SUBSTRING(name, LENGTH('#{_team_name_prefix} Team_') + 1) AS UNSIGNED) DESC")
                  .first
    counter = last_team ? last_team.name.scan(/\d+/).first.to_i + 1 : 1
    team_name = "#{_team_name_prefix} Team_#{counter}"
```

#### 8. Information Expert

- **Class/Module:** `Team`
- **Line:** 27
- **Confidence:** 90%
- **Reason:** Method `copy_content` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.copy_content(source, destination)
    source.each do |each_element|
      each_element.copy(destination.id)
    end
  end
```

#### 9. Information Expert

- **Class/Module:** `Team`
- **Line:** 80
- **Confidence:** 95%
- **Reason:** Method `add_member` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def add_member(user, _assignment_id = nil)
    raise "The user #{user.name} is already a member of the team #{name}" if user?(user)

    can_add_member = false
    unless full?
      can_add_member = true
```

#### 10. Information Expert

- **Class/Module:** `Team`
- **Line:** 96
- **Confidence:** 90%
- **Reason:** Method `size` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.size(team_id)
    #TeamsParticipant.where(team_id: team_id).count
    count = 0
    members = TeamsParticipant.where(team_id: team_id)
    members.each do |member|
      member_name = member.name
```

#### 11. Information Expert

- **Class/Module:** `Team`
- **Line:** 110
- **Confidence:** 95%
- **Reason:** Method `copy_members` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def copy_members(new_team)
    members = TeamsParticipant.where(team_id: id)
    members.each do |member|
      t_user = TeamsParticipant.create(team_id: new_team.id, user_id: member.user_id)
      parent = Object.const_get(parent_model).find(parent_id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
```

#### 12. Information Expert

- **Class/Module:** `Team`
- **Line:** 120
- **Confidence:** 85%
- **Reason:** Method `check_for_existing` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.check_for_existing(parent, name, team_type)
    list = Object.const_get(team_type + 'Team').where(parent_id: parent.id, name: name)
    raise TeamExistsError, "The team name #{name} is already in use." unless list.empty?
  end
```

#### 13. Information Expert

- **Class/Module:** `Team`
- **Line:** 128
- **Confidence:** 95%
- **Reason:** Method `randomize_all_by_parent` manipulates external state 19 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.randomize_all_by_parent(parent, team_type, min_team_size)
    participants = Participant.where(parent_id: parent.id, type: parent.class.to_s + 'Participant', can_mentor: [false, nil])
    participants = participants.sort { rand(-1..1) }
    users = participants.map { |p| User.find(p.user_id) }.to_a
    # find teams still need team members and users who are not in any team
    teams = Team.where(parent_id: parent.id, type: parent.class.to_s + 'Team').to_a
```

#### 14. Information Expert

- **Class/Module:** `Team`
- **Line:** 150
- **Confidence:** 95%
- **Reason:** Method `create_team_from_single_users` manipulates external state 11 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.create_team_from_single_users(min_team_size, parent, team_type, users)
    num_of_teams = users.length.fdiv(min_team_size).ceil
    next_team_member_index = 0
    (1..num_of_teams).to_a.each do |i|
      team = Object.const_get(team_type + 'Team').create(name: 'Team_' + i.to_s, parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: team.id)
```

#### 15. Information Expert

- **Class/Module:** `Team`
- **Line:** 167
- **Confidence:** 95%
- **Reason:** Method `assign_single_users_to_teams` manipulates external state 10 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.assign_single_users_to_teams(min_team_size, parent, teams, users)
    teams.each do |team|
      curr_team_size = Team.size(team.id)
      member_num_difference = min_team_size - curr_team_size
      while member_num_difference > 0
        team.add_member(users.first, parent.id)
```

#### 16. Information Expert

- **Class/Module:** `Team`
- **Line:** 182
- **Confidence:** 85%
- **Reason:** Method `generate_team_name` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.generate_team_name(_team_name_prefix = '')
    last_team = Team.where('name LIKE ?', "#{_team_name_prefix} Team_%")
                  .order("CAST(SUBSTRING(name, LENGTH('#{_team_name_prefix} Team_') + 1) AS UNSIGNED) DESC")
                  .first
    counter = last_team ? last_team.name.scan(/\d+/).first.to_i + 1 : 1
    team_name = "#{_team_name_prefix} Team_#{counter}"
```

#### 17. Information Expert

- **Class/Module:** `Team`
- **Line:** 192
- **Confidence:** 85%
- **Reason:** Method `import_team_members` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def import_team_members(row_hash)
    row_hash[:teammembers].each_with_index do |teammate, _index|
      user = User.find_by(name: teammate.to_s)
      if user.nil?
        raise ImportError, "The user '#{teammate}' was not found. <a href='/users/new'>Create</a> this user?"
      else
```

#### 18. Information Expert

- **Class/Module:** `Team`
- **Line:** 204
- **Confidence:** 95%
- **Reason:** Method `import` manipulates external state 7 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.import(row_hash, id, options, teamtype)
    raise ArgumentError, 'Not enough fields on this line.' if row_hash.empty? || (row_hash[:teammembers].empty? && (options[:has_teamname] == 'true_first' || options[:has_teamname] == 'true_last')) || (row_hash[:teammembers].empty? && (options[:has_teamname] == 'true_first' || options[:has_teamname] == 'true_last'))
    if options[:has_teamname] == 'true_first' || options[:has_teamname] == 'true_last'
      name = row_hash[:teamname].to_s
      team = where(['name =? && parent_id =?', name, id]).first
      team_exists = !team.nil?
```

#### 19. Information Expert

- **Class/Module:** `Team`
- **Line:** 228
- **Confidence:** 95%
- **Reason:** Method `handle_duplicate` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.handle_duplicate(team, name, id, handle_dups, teamtype)
    return name if team.nil? # no duplicate
    return nil if handle_dups == 'ignore' # ignore: do not create the new team

    if handle_dups == 'rename' # rename: rename new team
      if teamtype.is_a?(CourseTeam)
```

#### 20. Information Expert

- **Class/Module:** `Team`
- **Line:** 248
- **Confidence:** 95%
- **Reason:** Method `export` manipulates external state 10 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.export(csv, parent_id, options, teamtype)
    if teamtype.is_a?(CourseTeam)
      teams = CourseTeam.where(parent_id: parent_id)
    elsif teamtype.is_a?(AssignmentTeam)
      teams = AssignmentTeam.where(parent_id: parent_id)
    end
```

#### 21. Information Expert

- **Class/Module:** `Team`
- **Line:** 269
- **Confidence:** 90%
- **Reason:** Method `create_team_and_node` manipulates external state 4 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.create_team_and_node(id)
    parent = parent_model id # current_task will be either a course object or an assignment object.
    team_name = Team.generate_team_name(parent.name)
    team = create(name: team_name, parent_id: id)
    # new teamnode will have current_task.id as parent_id and team_id as node_object_id.
    TeamNode.create(parent_id: id, node_object_id: team.id)
```

#### 22. Information Expert

- **Class/Module:** `Team`
- **Line:** 294
- **Confidence:** 85%
- **Reason:** Method `create_team_with_users` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.create_team_with_users(parent_id, user_ids)
    team = create_team_and_node(parent_id)

    user_ids.each do |user_id|
      remove_user_from_previous_team(parent_id, user_id)
```

#### 23. Information Expert

- **Class/Module:** `Team`
- **Line:** 307
- **Confidence:** 85%
- **Reason:** Method `remove_user_from_previous_team` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.remove_user_from_previous_team(parent_id, user_id)
    team_participant = TeamsParticipant.where(user_id: user_id).find { |team_participant_obj| team_participant_obj.team.parent_id == parent_id }
    begin
      team_participant.destroy
    rescue StandardError
      nil
```

#### 24. Information Expert

- **Class/Module:** `Team`
- **Line:** 316
- **Confidence:** 95%
- **Reason:** Method `find_team_participants` manipulates external state 6 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.find_team_participants(assignment_id, user_id)
    TeamsParticipant.joins('INNER JOIN teams ON teams_participants.team_id = teams.id')
             .select('teams.id as t_id')
             .where('teams.parent_id = ? and teams_participants.user_id = ?', assignment_id, user_id)
  end
```

#### 25. Encapsulation

- **Class/Module:** `Team`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Has 100.0% public methods (limit: 60.0%).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class Team < ApplicationRecord
  has_many :teams_participants, dependent: :destroy
  has_many :users, through: :teams_participants
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail
```

### app/models/team_user_node.rb

**Status:** modified
**Changes:** +5 / -5

#### 1. Single Responsibility Principle

- **Class/Module:** `TeamUserNode`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class exposes 4 methods (limit: 4).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamUserNode < Node
  belongs_to :node_object, class_name: 'TeamsParticipant'
  # attr_accessible :parent_id, :node_object_id  # unnecessary protected attributes

  def self.table
    'teams_participants'
  end
```

#### 2. Information Expert

- **Class/Module:** `TeamUserNode`
- **Line:** 13
- **Confidence:** 95%
- **Reason:** Method `get` manipulates external state 6 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.get(parent_id)
    nodes = Node.joins('INNER JOIN teams_participants ON nodes.node_object_id = teams_participants.id')
                .select('nodes.*')
                .where("nodes.type = 'TeamUserNode'")
    nodes.where('teams_participants.team_id = ?', parent_id) if parent_id
  end
```

#### 3. Encapsulation

- **Class/Module:** `TeamUserNode`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Has 100.0% public methods (limit: 60.0%).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamUserNode < Node
  belongs_to :node_object, class_name: 'TeamsParticipant'
  # attr_accessible :parent_id, :node_object_id  # unnecessary protected attributes

  def self.table
    'teams_participants'
  end
```

### app/models/teams_participant.rb

**Status:** added
**Changes:** +72 / -0

#### 1. Single Responsibility Principle

- **Class/Module:** `TeamsParticipant`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Class exposes 8 methods (limit: 4).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamsParticipant < ApplicationRecord
  belongs_to :team
  belongs_to :participant

  # paper_trail, node, etc
  has_one    :team_participant_node,
             foreign_key: 'node_object_id',
             dependent:   :destroy
```

#### 2. Law of Demeter

- **Class/Module:** `TeamsParticipant`
- **Line:** 25
- **Confidence:** 80%
- **Reason:** Method `delete` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete
    team_participant_node&.destroy
    t = team
    destroy
    t.destroy if t.teams_participants.empty?
  end
```

#### 3. Law of Demeter

- **Class/Module:** `TeamsParticipant`
- **Line:** 69
- **Confidence:** 80%
- **Reason:** Method `team_id` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.team_id(assignment_id, user_id)
    each_for(user_id).find { |tp| tp.team.parent_id == assignment_id }&.team_id
  end
```

#### 4. Information Expert

- **Class/Module:** `TeamsParticipant`
- **Line:** 25
- **Confidence:** 80%
- **Reason:** Method `delete` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def delete
    team_participant_node&.destroy
    t = team
    destroy
    t.destroy if t.teams_participants.empty?
  end
```

#### 5. Information Expert

- **Class/Module:** `TeamsParticipant`
- **Line:** 33
- **Confidence:** 80%
- **Reason:** Method `remove_team` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.remove_team(user_id, team_id)
    jp = joins(participant: :user)
           .where('participants.user_id = ? AND team_id = ?', user_id, team_id)
           .first
    jp&.destroy
  end
```

#### 6. Information Expert

- **Class/Module:** `TeamsParticipant`
- **Line:** 51
- **Confidence:** 85%
- **Reason:** Method `add_member_to_invited_team` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
    success = false
    each_for(invitee_user_id) do |tp|
      next unless (asg_team = AssignmentTeam.find_by(id: tp.team_id, parent_id: assignment_id))
      invited_participant = Participant.find_by(user_id: invited_user_id, parent_id: assignment_id)
      success = asg_team.add_member(invited_participant) if invited_participant
```

#### 7. Information Expert

- **Class/Module:** `TeamsParticipant`
- **Line:** 62
- **Confidence:** 80%
- **Reason:** Method `each_for` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.each_for(user_id, &block)
    joins(participant: :user)
      .where('participants.user_id = ?', user_id)
      .each(&block)
  end
```

#### 8. Information Expert

- **Class/Module:** `TeamsParticipant`
- **Line:** 69
- **Confidence:** 80%
- **Reason:** Method `team_id` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.team_id(assignment_id, user_id)
    each_for(user_id).find { |tp| tp.team.parent_id == assignment_id }&.team_id
  end
```

#### 9. Encapsulation

- **Class/Module:** `TeamsParticipant`
- **Line:** 1
- **Confidence:** 95%
- **Reason:** Has 100.0% public methods (limit: 60.0%).
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamsParticipant < ApplicationRecord
  belongs_to :team
  belongs_to :participant

  # paper_trail, node, etc
  has_one    :team_participant_node,
             foreign_key: 'node_object_id',
             dependent:   :destroy
```

### app/models/teams_user.rb

**Status:** removed
**Changes:** +0 / -76

> No design principle violations detected.

### app/models/user.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### config/routes.rb

**Status:** modified
**Changes:** +114 / -116

> No design principle violations detected.

### db/migrate/002_initialize_custom.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### db/migrate/019_create_teams_users.rb

**Status:** modified
**Changes:** +7 / -7

#### 1. Information Expert

- **Class/Module:** `CreateTeamsUsers`
- **Line:** 2
- **Confidence:** 85%
- **Reason:** Method `up` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.up
    create_table 'teams_participants', force: true do |t|
      t.column 'team_id', :integer
      t.column 'user_id', :integer
    end
```

#### 2. Overuse of Class Methods

- **Class/Module:** `CreateTeamsUsers`
- **Line:** 1
- **Confidence:** 90%
- **Reason:** Defines 2 class methods and 0 instance method(s); consider instance state.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class CreateTeamsUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table 'teams_participants', force: true do |t|
      t.column 'team_id', :integer
      t.column 'user_id', :integer
    end

    add_index 'teams_participants', ['team_id'], name: 'fk_users_teams'
```

### db/migrate/066_create_team_user_nodes.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Information Expert

- **Class/Module:** `CreateTeamUserNodes`
- **Line:** 2
- **Confidence:** 95%
- **Reason:** Method `up` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.up
    begin
      remove_column :teams_participants, :assignment_id
    rescue StandardError
    end
```

#### 2. Information Expert

- **Class/Module:** `CreateTeamUserNodes`
- **Line:** 17
- **Confidence:** 80%
- **Reason:** Method `down` manipulates external state 2 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.down
    teamsusers = TeamsUser.all
    teamsusers.each(&:destroy)

    add_column :teams_participants, :assignment_id, :integer
  end
```

#### 3. Overuse of Class Methods

- **Class/Module:** `CreateTeamUserNodes`
- **Line:** 1
- **Confidence:** 90%
- **Reason:** Defines 2 class methods and 0 instance method(s); consider instance state.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class CreateTeamUserNodes < ActiveRecord::Migration[4.2]
  def self.up
    begin
      remove_column :teams_participants, :assignment_id
    rescue StandardError
    end

    teamsusers = TeamsUser.all
```

### db/migrate/20121018001330_change_teams_users_to_teams_participants.rb

**Status:** removed
**Changes:** +0 / -8

> No design principle violations detected.

### db/migrate/20131103014327_create_participant_score_views.rb

**Status:** modified
**Changes:** +1 / -1

#### 1. Information Expert

- **Class/Module:** `CreateParticipantScoreViews`
- **Line:** 2
- **Confidence:** 95%
- **Reason:** Method `up` manipulates external state 20 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.up
    execute <<-SQL
      CREATE VIEW participant_score_views AS SELECT r.id response_id,s.answer,q.weight,qs.name questionaire_type,qs.max_question_score,t.id as team_id,user_id as participant_id , t.parent_id as assignment_id
 FROM answers s ,responses r, response_maps rm, questions q, questionnaires qs , teams_participants tu , teams t
 WHERE  rm.id = r.map_id AND r.id=s.response_id AND q.id = s.question_id AND qs.id = q.questionnaire_id    AND tu.team_id = rm.reviewee_id   AND tu.team_id = t.id
    SQL
```

#### 2. Overuse of Class Methods

- **Class/Module:** `CreateParticipantScoreViews`
- **Line:** 1
- **Confidence:** 90%
- **Reason:** Defines 2 class methods and 0 instance method(s); consider instance state.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class CreateParticipantScoreViews < ActiveRecord::Migration[4.2]
  def self.up
    execute <<-SQL
      CREATE VIEW participant_score_views AS SELECT r.id response_id,s.answer,q.weight,qs.name questionaire_type,qs.max_question_score,t.id as team_id,user_id as participant_id , t.parent_id as assignment_id
 FROM answers s ,responses r, response_maps rm, questions q, questionnaires qs , teams_participants tu , teams t
 WHERE  rm.id = r.map_id AND r.id=s.response_id AND q.id = s.question_id AND qs.id = q.questionnaire_id    AND tu.team_id = rm.reviewee_id   AND tu.team_id = t.id
    SQL
  end
```

### db/migrate/20141111010259_add_index_to_response_maps.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Overuse of Class Methods

- **Class/Module:** `AddIndexToResponseMaps`
- **Line:** 1
- **Confidence:** 90%
- **Reason:** Defines 2 class methods and 0 instance method(s); consider instance state.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class AddIndexToResponseMaps < ActiveRecord::Migration[4.2]
  def self.up
    # add_index :response_maps, :reviewee_id
    # add_index :response_maps, :reviewer_id
    # add_index :response_maps, :reviewed_object_id

    # add_index :teams_participants, :user_id
```

### db/migrate/20141204022200_add_team_index_to_teams_users.rb

**Status:** modified
**Changes:** +2 / -2

#### 1. Overuse of Class Methods

- **Class/Module:** `AddTeamIndexToTeamsUsers`
- **Line:** 1
- **Confidence:** 90%
- **Reason:** Defines 2 class methods and 0 instance method(s); consider instance state.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class AddTeamIndexToTeamsUsers < ActiveRecord::Migration[4.2]
   def self.up
      #add_index :teams_participants, :team_id
   end

  def self.down
    # remove_index :teams_participants, :team_id
  end
```

### db/migrate/20150527105416_convert_all_individual_assignments_to_one_member_team_assignments.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### db/migrate/20211110161054_add_duty_id_to_teams_users.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### db/migrate/20220405141744_add_pair_programming_status_to_teams_users.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### db/migrate/20230415194444_add_participant_id_and_populate.rb

**Status:** modified
**Changes:** +6 / -6

#### 1. Law of Demeter

- **Class/Module:** `AddParticipantIdAndPopulate`
- **Line:** 3
- **Confidence:** 80%
- **Reason:** Method `up` contains a call chain of length 3.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def up
    add_column :teams_participants, :participant_id, :integer, limit: 4, index: true
    add_foreign_key :teams_participants, :participants
    # firstly, fetch all TeamsUser rows
    teams_participants = TeamsUser.all
    # for each TeamsUser row
```

#### 2. Information Expert

- **Class/Module:** `AddParticipantIdAndPopulate`
- **Line:** 3
- **Confidence:** 95%
- **Reason:** Method `up` manipulates external state 9 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def up
    add_column :teams_participants, :participant_id, :integer, limit: 4, index: true
    add_foreign_key :teams_participants, :participants
    # firstly, fetch all TeamsUser rows
    teams_participants = TeamsUser.all
    # for each TeamsUser row
```

### db/migrate/20240319000001_rename_teams_users_to_teams_participants.rb

**Status:** added
**Changes:** +15 / -0

> No design principle violations detected.

### db/migrate/20240320000002_add_participant_id_to_teams_participants.rb

**Status:** added
**Changes:** +28 / -0

#### 1. Information Expert

- **Class/Module:** `AddParticipantIdToTeamsParticipants`
- **Line:** 5
- **Confidence:** 95%
- **Reason:** Method `up` manipulates external state 5 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def up
      unless column_exists?(:teams_participants, :participant_id)
        add_column :teams_participants, :participant_id, :integer
        add_index  :teams_participants, :participant_id, algorithm: :concurrently
  
        # back‐fill: for each row, find the Participant whose user_id = old user_id
```

### db/migrate/20240320000003_remove_user_id_from_teams_participants.rb

**Status:** added
**Changes:** +18 / -0

> No design principle violations detected.

### db/migrate/20240320000004_add_fks_to_teams_participants.rb

**Status:** added
**Changes:** +8 / -0

> No design principle violations detected.

### db/migrate_save/020_teams_users.rb

**Status:** modified
**Changes:** +5 / -5

#### 1. Information Expert

- **Class/Module:** `TeamsUsers`
- **Line:** 2
- **Confidence:** 85%
- **Reason:** Method `up` manipulates external state 3 times vs 0 local accesses.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
def self.up
    create_table :teams_participants do |t| # maps users to teams; in rare cases, a single individual is on > 1 team for an assgt.
      t.column :team_id, :integer
      t.column :user_id, :integer
    end
    execute "alter table teams_participants
```

#### 2. Overuse of Class Methods

- **Class/Module:** `TeamsUsers`
- **Line:** 1
- **Confidence:** 90%
- **Reason:** Defines 2 class methods and 0 instance method(s); consider instance state.
- **Note:** This violation is in code that was changed in this PR

**Analysis:** Heuristic fallback confirmation based on strong static signals.

**Suggestion:** Extract collaborators and follow the cited principle.

**Code Context:**
```ruby
class TeamsUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :teams_participants do |t| # maps users to teams; in rare cases, a single individual is on > 1 team for an assgt.
      t.column :team_id, :integer
      t.column :user_id, :integer
    end
    execute "alter table teams_participants
             add constraint fk_users_teams
```

### db/schema.rb

**Status:** modified
**Changes:** +10 / -11

> No design principle violations detected.

### spec/controllers/advertise_for_partner_controller_spec.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### spec/controllers/invitations_controller_spec.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### spec/controllers/lottery_controller_spec.rb

**Status:** modified
**Changes:** +12 / -12

> No design principle violations detected.

### spec/controllers/pair_programming_controller_spec.rb

**Status:** modified
**Changes:** +6 / -6

> No design principle violations detected.

### spec/controllers/popup_controller_spec.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### spec/controllers/review_mapping_controller_spec.rb

**Status:** modified
**Changes:** +3 / -3

> No design principle violations detected.

### spec/controllers/sign_up_sheet_controller_spec.rb

**Status:** modified
**Changes:** +5 / -5

> No design principle violations detected.

### spec/controllers/student_teams_controller_spec.rb

**Status:** modified
**Changes:** +4 / -4

> No design principle violations detected.

### spec/controllers/teams_participants_controller_spec.rb

**Status:** added
**Changes:** +179 / -0

> No design principle violations detected.

### spec/controllers/teams_users_controller_spec.rb

**Status:** removed
**Changes:** +0 / -340

> No design principle violations detected.

### spec/factories/factories.rb

**Status:** modified
**Changes:** +504 / -510

> No design principle violations detected.

### spec/features/airbrake_exception_errors_feature_tests_spec.rb

**Status:** modified
**Changes:** +3 / -3

> No design principle violations detected.

### spec/features/assignment_team_member_spec.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### spec/features/bookmark_review_spec.rb

**Status:** modified
**Changes:** +3 / -3

> No design principle violations detected.

### spec/features/instructor_do_review_spec.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### spec/features/list_teams_spec.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### spec/features/peer_review_spec.rb

**Status:** modified
**Changes:** +3 / -3

> No design principle violations detected.

### spec/features/quiz_spec.rb

**Status:** modified
**Changes:** +4 / -4

> No design principle violations detected.

### spec/features/review_mapping_spec.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### spec/features/teams_as_reviewers_spec.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### spec/features/view_team_spec.rb

**Status:** modified
**Changes:** +3 / -3

> No design principle violations detected.

### spec/helpers/review_mapping_helper_spec.rb

**Status:** modified
**Changes:** +4 / -4

> No design principle violations detected.

### spec/models/assignment_participant_spec.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

### spec/models/assignment_spec.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### spec/models/assignment_team_spec.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### spec/models/cake_spec.rb

**Status:** modified
**Changes:** +4 / -4

> No design principle violations detected.

### spec/models/course_team_spec.rb

**Status:** modified
**Changes:** +3 / -3

> No design principle violations detected.

### spec/models/duty_spec.rb

**Status:** modified
**Changes:** +6 / -6

> No design principle violations detected.

### spec/models/invitation_spec.rb

**Status:** modified
**Changes:** +19 / -19

> No design principle violations detected.

### spec/models/mentor_management_spec.rb

**Status:** modified
**Changes:** +6 / -6

> No design principle violations detected.

### spec/models/participant_spec.rb

**Status:** modified
**Changes:** +6 / -6

> No design principle violations detected.

### spec/models/review_response_map_spec.rb

**Status:** modified
**Changes:** +2 / -2

> No design principle violations detected.

### spec/models/student_task_spec.rb

**Status:** modified
**Changes:** +5 / -5

> No design principle violations detected.

### spec/models/tag_prompt_deployment_spec.rb

**Status:** modified
**Changes:** +9 / -9

> No design principle violations detected.

### spec/models/team_spec.rb

**Status:** modified
**Changes:** +8 / -8

> No design principle violations detected.

### spec/models/teams_participant_spec.rb

**Status:** added
**Changes:** +132 / -0

> No design principle violations detected.

### spec/support/teams_shared.rb

**Status:** modified
**Changes:** +1 / -1

> No design principle violations detected.

---

*Report generated at 2026-01-22T12:57:27-05:00*