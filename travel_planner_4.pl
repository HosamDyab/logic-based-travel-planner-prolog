% travel_planner.pl
% A Prolog-based travel planner for Cairo, Aswan, and PortSaid, generating trip plans
% with enhanced recommendations, attraction linking, budget optimization, and clean formatting.

:- module(travel_planner_4, [
    plan_trip/8, % Keep exported if direct call needed
    start_planner/0, % Export the interactive starter
    submit_hotel_review/4,
    update_hotel/5
]).

% Import required libraries
:- use_module(library(lists), [member/2, subtract/3, sum_list/2, reverse/2, flatten/2, nth1/3, list_to_set/2]). % Added list_to_set
:- use_module(library(apply), [maplist/3, maplist/4]).
:- use_module(library(readutil), [read_line_to_string/2]). % For user input

% Ensure predicates are dynamic
:- dynamic(hotel/5).
:- dynamic(hotel_review/3).

% --- Facts ---
% (Facts remain the same as before - omitted for brevity)
% hotel(City, Name, PricePerNight, Rating, Demand)
hotel('Cairo', 'Hilton Cairo Nile', 1200, 4.7, high).
hotel('Cairo', 'InterContinental Cairo Semiramis', 1300, 4.8, high).
hotel('Cairo', 'Marriott Mena House', 1400, 4.9, high).
hotel('Cairo', 'Four Seasons Nile Plaza', 1500, 4.8, high).
hotel('Cairo', 'The Nile Ritz-Carlton', 1250, 4.7, high).
hotel('Cairo', 'Sofitel Cairo Downtown Nile', 1100, 4.6, high).
hotel('Cairo', 'Budget Hotel Cairo', 800, 4.0, high).
hotel('Cairo', 'Economy Hotel Cairo', 600, 3.8, high).
hotel('Aswan', 'Sofitel Legend Old Cataract', 1600, 4.9, high).
hotel('Aswan', 'Mövenpick Resort Aswan', 1000, 4.6, high).
hotel('Aswan', 'Hilton Aswan', 1100, 4.7, high).
hotel('Aswan', 'Anakato Nubian Experience', 900, 4.5, low).
hotel('Aswan', 'Pyramisa Isis Island', 950, 4.4, high).
hotel('PortSaid', 'Resta Port Said Hotel', 800, 4.3, high).
hotel('PortSaid', 'Grand Hotel Port Said', 600, 4.0, low).
hotel('PortSaid', 'Helnan Port Said', 850, 4.4, high).
hotel('PortSaid', 'Porto Said Resort', 750, 4.2, high).
hotel('PortSaid', 'Jewel Port Said', 700, 4.1, high).

% hotel_review(HotelName, Rating, Comment)
hotel_review('Hilton Cairo Nile', 4.5, 'Stunning Nile views, impeccable service').
hotel_review('InterContinental Cairo Semiramis', 4.8, 'Luxurious rooms, fantastic dining').
hotel_review('Marriott Mena House', 4.9, 'Iconic hotel with pyramid views').
hotel_review('Four Seasons Nile Plaza', 4.7, 'Elegant ambiance, top-notch spa').
hotel_review('The Nile Ritz-Carlton', 4.6, 'Central location, vibrant atmosphere').
hotel_review('Sofitel Cairo Downtown Nile', 4.5, 'Modern design, amazing rooftop bar').
hotel_review('Sofitel Legend Old Cataract', 4.9, 'Historic charm, breathtaking Nile views').
hotel_review('Mövenpick Resort Aswan', 4.6, 'Serene island setting, excellent pool').
hotel_review('Hilton Aswan', 4.7, 'Comfortable rooms, friendly staff').
hotel_review('Anakato Nubian Experience', 4.4, 'Unique cultural stay, warm hospitality').
hotel_review('Pyramisa Isis Island', 4.3, 'Spacious grounds, good value').
hotel_review('Resta Port Said Hotel', 4.2, 'Clean rooms, seafront location').
hotel_review('Grand Hotel Port Said', 3.8, 'Decent budget option, good location').
hotel_review('Helnan Port Said', 4.4, 'Modern amenities, excellent service').
hotel_review('Porto Said Resort', 4.1, 'Nice beach access, family-friendly').
hotel_review('Jewel Port Said', 4.0, 'Affordable, clean, convenient').

% transport(City, Mode, Cost, Distance, Duration)
transport('Cairo', 'Metro', 10, 15, 0.5).
transport('Cairo', 'Taxi', 50, 15, 0.75).
transport('Cairo', 'Bus', 8, 20, 1.0).
transport('Cairo', 'Train', 40, 200, 2.5).
transport('Aswan', 'Felucca', 100, 5, 1.5).
transport('Aswan', 'Minibus', 15, 10, 0.5).
transport('Aswan', 'Taxi', 30, 10, 0.4).
transport('Aswan', 'Train', 60, 300, 4.0).
transport('PortSaid', 'Ferry', 20, 10, 0.6).
transport('PortSaid', 'Taxi', 25, 8, 0.3).
transport('PortSaid', 'Bus', 12, 15, 0.7).
transport('PortSaid', 'Minibus', 10, 8, 0.4).

% activity(City, Name, Cost, Duration, Category, Suitability)
activity('Cairo', 'Pyramid Tour', 500, 4, cultural, group).
activity('Cairo', 'Egyptian Museum Visit', 200, 3, cultural, solo).
activity('Cairo', 'Nile River Cruise', 300, 2, leisure, family).
activity('Cairo', 'Desert Quad Biking', 600, 3, adventure, group).
activity('Cairo', 'Khan el-Khalili Bazaar', 100, 2, cultural, solo).
activity('Cairo', 'Citadel and Mohamed Ali Mosque Tour', 350, 3, cultural, group).
activity('Cairo', 'Sound and Light Show at Pyramids', 250, 1.5, leisure, family).
activity('Cairo', 'Camel Ride at Giza', 200, 1, adventure, solo).
activity('Cairo', 'Coptic Cairo Walking Tour', 150, 2.5, cultural, group).
activity('Cairo', 'Street Food Tour', 100, 2, leisure, solo).
activity('Aswan', 'Philae Temple Tour', 400, 3, cultural, group).
activity('Aswan', 'Felucca Sunset Sail', 150, 1.5, leisure, family).
activity('Aswan', 'Nubian Village Visit', 250, 4, cultural, solo).
activity('Aswan', 'High Dam Tour', 200, 2, cultural, group).
activity('Aswan', 'Sandboarding Adventure', 350, 3, adventure, group).
activity('Aswan', 'Abu Simbel Day Trip', 800, 8, cultural, group).
activity('Aswan', 'Botanical Garden Visit', 100, 1.5, leisure, family).
activity('Aswan', 'Nile Kayaking', 300, 2, adventure, solo).
activity('Aswan', 'Aswan Market Tour', 120, 2, cultural, solo).
activity('Aswan', 'Stargazing in the Desert', 400, 4, leisure, group).
activity('PortSaid', 'Suez Canal Boat Tour', 300, 2.5, cultural, group).
activity('PortSaid', 'Beach Relaxation', 50, 4, leisure, family).
activity('PortSaid', 'PortSaid Museum Visit', 100, 2, cultural, solo).
activity('PortSaid', 'Water Sports', 400, 3, adventure, group).
activity('PortSaid', 'Coastal Bike Tour', 150, 2, leisure, solo).
activity('PortSaid', 'Fishing Trip', 250, 3, adventure, group).
activity('PortSaid', 'Corniche Evening Walk', 50, 1.5, leisure, family).
activity('PortSaid', 'Military Museum Visit', 80, 1.5, cultural, solo).
activity('PortSaid', 'Kite Surfing Lesson', 500, 2, adventure, solo).
activity('PortSaid', 'Local Cafe Hopping', 100, 2, leisure, group).

% daily_time_constraint(MaxHoursPerDay) - Predefined valid values
daily_time_constraint(4).
daily_time_constraint(6).
daily_time_constraint(8).
daily_time_constraint(10).

% food_cost(City, DailyCost) - Different budget levels
food_cost('Cairo', 250). % Low
food_cost('Cairo', 400). % Mid
food_cost('Cairo', 600). % High
food_cost('Aswan', 120). % Low
food_cost('Aswan', 250). % Mid
food_cost('Aswan', 380). % High
food_cost('PortSaid', 150). % Low
food_cost('PortSaid', 280). % Mid
food_cost('PortSaid', 450). % High

% month_to_number(Month, Number)
month_to_number('January', 1).
month_to_number('February', 2).
month_to_number('March', 3).
month_to_number('April', 4).
month_to_number('May', 5).
month_to_number('June', 6).
month_to_number('July', 7).
month_to_number('August', 8).
month_to_number('September', 9).
month_to_number('October', 10).
month_to_number('November', 11).
month_to_number('December', 12).

% season(Month, Season)
season('January', winter).
season('February', winter).
season('March', spring).
season('April', spring).
season('May', spring).
season('June', summer).
season('July', summer).
season('August', summer).
season('September', autumn).
season('October', autumn).
season('November', autumn).
season('December', winter).

% city(Name, BestSeason, Currency)
city('Cairo', spring, 'EGP').
city('Cairo', autumn, 'EGP').
city('Aswan', winter, 'EGP').
city('Aswan', spring, 'EGP').
city('PortSaid', summer, 'EGP').
city('PortSaid', spring, 'EGP').

% attraction(City, Name, Type, VisitingHours[Open, Close])
attraction('Cairo', 'Giza Pyramids', landmark, [8, 17]).
attraction('Cairo', 'Egyptian Museum', cultural_site, [9, 17]).
attraction('Cairo', 'Khan el-Khalili', tourist_spot, [9, 22]).
attraction('Cairo', 'Citadel of Saladin', cultural_site, [8, 16]).
attraction('Cairo', 'Coptic Cairo', cultural_site, [9, 17]).
attraction('Aswan', 'Philae Temple', cultural_site, [7, 16]).
attraction('Aswan', 'Abu Simbel', landmark, [6, 15]). % Often visited from Aswan
attraction('Aswan', 'Nubian Village', tourist_spot, [8, 18]).
attraction('Aswan', 'Aswan High Dam', landmark, [8, 16]).
attraction('Aswan', 'Botanical Garden', tourist_spot, [8, 17]).
attraction('PortSaid', 'Suez Canal', landmark, [7, 17]).
attraction('PortSaid', 'PortSaid Military Museum', cultural_site, [9, 15]).
attraction('PortSaid', 'PortSaid Corniche', tourist_spot, [0, 24]). % Assuming always accessible
attraction('PortSaid', 'Al-Nasr Museum', cultural_site, [9, 16]).
attraction('PortSaid', 'Ferial Garden', tourist_spot, [8, 20]).

% activity_attraction_link(ActivityName, AttractionName) - Explicit links
activity_attraction_link('Pyramid Tour', 'Giza Pyramids').
activity_attraction_link('Egyptian Museum Visit', 'Egyptian Museum').
activity_attraction_link('Khan el-Khalili Bazaar', 'Khan el-Khalili').
activity_attraction_link('Citadel and Mohamed Ali Mosque Tour', 'Citadel of Saladin').
activity_attraction_link('Coptic Cairo Walking Tour', 'Coptic Cairo').
activity_attraction_link('Camel Ride at Giza', 'Giza Pyramids').
activity_attraction_link('Desert Quad Biking', 'Giza Pyramids'). % Assuming near Giza
activity_attraction_link('Philae Temple Tour', 'Philae Temple').
activity_attraction_link('Nubian Village Visit', 'Nubian Village').
activity_attraction_link('High Dam Tour', 'Aswan High Dam').
activity_attraction_link('Abu Simbel Day Trip', 'Abu Simbel').
activity_attraction_link('Botanical Garden Visit', 'Botanical Garden').
activity_attraction_link('Suez Canal Boat Tour', 'Suez Canal').
activity_attraction_link('PortSaid Museum Visit', 'Al-Nasr Museum'). % Assuming this is the main one
activity_attraction_link('Military Museum Visit', 'PortSaid Military Museum').
activity_attraction_link('Corniche Evening Walk', 'PortSaid Corniche').

% --- Rules ---

% ============================================================
% Interactive Planner Start Predicate
% ============================================================
start_planner :-
    write('--- Welcome to the Travel Planner ---'), nl,
    prompt_read_string('Enter your name (UserID): ', UserID),
    prompt_read_city('Enter destination city (Cairo, Aswan, PortSaid): ', City),
    prompt_read_integer('Enter trip duration in days: ', DurationDays),
    prompt_read_month('Enter travel month (e.g., January, February): ', Month),
    prompt_read_hours('Enter max activity hours per day (4, 6, 8, 10): ', MaxHoursPerDay),
    prompt_read_integer('Enter group size: ', GroupSize),
    prompt_read_number('Enter minimum budget (EGP): ', MinBudget),
    prompt_read_max_budget('Enter maximum budget (EGP): ', MinBudget, MaxBudget),
    nl, write('--- Generating Plan... ---'), nl, nl,
    % Call the main planner, catch errors locally
    catch(
        plan_trip(UserID, City, DurationDays, Month, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget),
        Error,
        (   write('Error during planning: '), writeln(Error),
            write('Failed to generate a complete plan. Please check inputs or adjust constraints.'), nl
        )
    ),
    nl, write('--- Planner Finished ---'), nl.

% Helper predicates for reading validated input
prompt_read_string(Prompt, Value) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, Value),
    ( Value \= "" -> true ; write('Input cannot be empty. Please try again.'), nl, prompt_read_string(Prompt, Value) ).

prompt_read_city(Prompt, AtomValue) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, StringValue),
    atom_string(AtomValue, StringValue), % Convert to atom
    ( member(AtomValue, ['Cairo', 'Aswan', 'PortSaid']) -> true
    ; write('Invalid city. Choose Cairo, Aswan, or PortSaid. Please try again.'), nl, prompt_read_city(Prompt, AtomValue)
    ).

prompt_read_month(Prompt, AtomValue) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, StringValue),
    atom_string(AtomValue, StringValue), % Convert to atom
    ( month_to_number(AtomValue, _) -> true
    ; write('Invalid month name (e.g., January). Please try again.'), nl, prompt_read_month(Prompt, AtomValue)
    ).

prompt_read_integer(Prompt, Value) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, StringValue),
    ( number_string(Value, StringValue), integer(Value), Value > 0 -> true
    ; write('Invalid input. Please enter a positive integer. Please try again.'), nl, prompt_read_integer(Prompt, Value)
    ).

prompt_read_number(Prompt, Value) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, StringValue),
    ( number_string(Value, StringValue), Value >= 0 -> true
    ; write('Invalid input. Please enter a non-negative number. Please try again.'), nl, prompt_read_number(Prompt, Value)
    ).

prompt_read_hours(Prompt, Value) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, StringValue),
    ( number_string(Value, StringValue), daily_time_constraint(Value) -> true
    ; write('Invalid input. Must be 4, 6, 8, or 10. Please try again.'), nl, prompt_read_hours(Prompt, Value)
    ).

prompt_read_max_budget(Prompt, MinBudget, MaxValue) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, StringValue),
    ( number_string(MaxValue, StringValue), MaxValue >= MinBudget -> true
    ; format(atom(Msg), 'Invalid input. Maximum budget must be a number >= minimum budget (~w). Please try again.', [MinBudget]),
      writeln(Msg),
      prompt_read_max_budget(Prompt, MinBudget, MaxValue)
    ).


% ============================================================
% Main Planning Logic
% ============================================================

% plan_trip(+UserID, +City, +DurationDays, +Month, +MaxHoursPerDay, +GroupSize, +MinBudget, +MaxBudget)
% Generates a travel plan with enhanced recommendations and budget handling.
plan_trip(UserID, City, DurationDays, Month, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget) :-
    % Input validation is now primarily handled by start_planner helpers, but keep internal checks too
    validate_inputs(DurationDays, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget),
    ( member(City, ['Cairo', 'Aswan', 'PortSaid']) -> true
    ; format(atom(ErrorMsg), 'Internal Error: Invalid city ~w.', [City]), throw(error(invalid_city, context(ErrorMsg)))
    ),
    ( month_to_number(Month, _) -> true
    ; format(atom(ErrorMsg), 'Internal Error: Invalid month ~w.', [Month]), throw(error(invalid_month, context(ErrorMsg)))
    ),
    check_season(City, Month, _Season), % Check and warn if needed
    catch(
        (   % Select components
            select_hotel(City, DurationDays, MinBudget, MaxBudget, HotelName, PricePerNight, Rating),
            select_transport(City, TransportMode, TransportCost),
            select_food_cost(City, MinBudget, MaxBudget, DailyFoodCost), % Budget-aware food cost selection
            collect_all_activities(City, AllActivitiesRaw), % Raw: Cost-Duration-Name

            % Distribute activities
            distribute_activities(DurationDays, MaxHoursPerDay, MaxBudget, MinBudget, PricePerNight, DailyFoodCost, TransportCost, AllActivitiesRaw,
                                  DailyActivitiesRaw, ActivityCosts, DailyActivityDetails), % DailyActivitiesRaw: List of lists of Cost-Duration-Name

            % Extract just names for easier processing later
            maplist(maplist(extract_activity_name), DailyActivitiesRaw, DailyActivities), % DailyActivities: List of lists of Names

            % Calculate total cost and check budget
            calculate_total_cost(DurationDays, PricePerNight, DailyFoodCost, TransportCost, ActivityCosts, TotalBudget),
            check_budget(TotalBudget, MaxBudget, MinBudget, BudgetStatus),

            % Print the plan
            print_travel_plan(UserID, City, DurationDays, GroupSize, HotelName, Rating, TransportMode, TransportCost,
                               DailyActivities, TotalBudget, PricePerNight, ActivityCosts, DailyFoodCost, DailyActivityDetails, BudgetStatus, AllActivitiesRaw, MinBudget, MaxBudget),
             !, % Cut: Commit to this first found solution, prevent backtracking for more plans
             true % Ensure the predicate succeeds after the cut

        ),
        Error, % Catch specific errors or general ones during the core planning
        (   handle_planning_error(Error, MinBudget, MaxBudget, MaxHoursPerDay), % Pass relevant context
            fail % Indicate failure after handling the error
        )
    ).


% Handle specific planning errors with suggestions
handle_planning_error(error(budget_out_of_range, context(ErrorMsg)), MinBudget, MaxBudget, _) :-
    format('Error: ~w~n', [ErrorMsg]),
    format('Suggestions to adjust budget:~n'),
    format('  - Choose a cheaper hotel (e.g., Economy Hotel Cairo, 600 EGP/night).~n'),
    format('  - Select fewer or cheaper activities (e.g., Khan el-Khalili Bazaar, 100 EGP).~n'),
    format('  - Opt for cheaper transport (e.g., Metro, 10 EGP).~n'),
    format('  - Reduce daily food budget (e.g., 250 EGP/day).~n'),
    % TotalBudget isn't available here reliably if error is early
    format('  - Check if MaxBudget (~w EGP) is sufficient for your choices.~n', [MaxBudget]),
    format('  - Check if MinBudget (~w EGP) is realistic.~n', [MinBudget]).

handle_planning_error(error(no_hotels_available, context(ErrorMsg)), MinBudget, MaxBudget, _) :-
    format('Error: ~w~n', [ErrorMsg]),
    format('Suggestions:~n'),
    format('  - Broaden budget range (Current: ~w - ~w EGP). The hotel cost must be 20-35%% of this range.~n', [MinBudget, MaxBudget]),
    format('  - Try a different city or duration.~n').

handle_planning_error(error(no_activities_available, context(ErrorMsg)), _, _, _) :-
     format('Error: ~w~n', [ErrorMsg]),
     format('This should not happen with the current data. Check activity facts.~n').

handle_planning_error(error(no_transport_available, context(ErrorMsg)), _, _, _) :-
     format('Error: ~w~n', [ErrorMsg]),
     format('This should not happen with the current data. Check transport facts.~n').

handle_planning_error(error(type_error(evaluable, _), _), MinBudget, MaxBudget, MaxHoursPerDay) :- % Often happens in cost calculation
    format('Error: Failed to calculate costs, possibly due to insufficient budget for activities or time constraints.~n'),
    format('Suggestions:~n'),
    format('  - Increase MaxHoursPerDay (current: ~w hours).~n', [MaxHoursPerDay]),
    format('  - Increase MaxBudget (current: ~w EGP).~n', [MaxBudget]),
    format('  - Decrease MinBudget (current: ~w EGP).~n', [MinBudget]),
    format('  - Try fewer days or a cheaper city.~n').

handle_planning_error(Error, _, _, _) :- % Catch-all for other errors
    format('An unexpected error occurred during planning: ~w~n', [Error]),
    format('Please check your inputs and the planner data.~n').


% submit_hotel_review(+UserID, +HotelName, +Rating, +Comment)
% Submits a hotel review.
submit_hotel_review(UserID, HotelName, Rating, Comment) :-
    ( hotel(_, HotelName, _, _, _) ->
        true
    ; format(atom(ErrorMsg), 'Hotel ~w does not exist', [HotelName]),
      throw(error(invalid_hotel, context(ErrorMsg)))
    ),
    ( number(Rating), Rating >= 0, Rating =< 5 ->
        true
    ; throw(error(invalid_rating, context('Rating must be a number between 0 and 5')))
    ),
    ( (atom(Comment); string(Comment)), Comment \= '', Comment \= "" ->
        true
    ; throw(error(invalid_comment, context('Comment cannot be empty')))
    ),
    assertz(hotel_review(HotelName, Rating, Comment)),
    format('Review submitted by ~w for ~w: ~1f stars, "~w"~n', [UserID, HotelName, Rating, Comment]).

% update_hotel(+UserID, +City, +OldHotelName, +NewHotelName, +NewPrice)
% Replaces a hotel's name and price. Retains rating and demand.
update_hotel(UserID, City, OldHotelName, NewHotelName, NewPrice) :-
    ( hotel(City, OldHotelName, OldPrice, OldRating, OldDemand) ->
        true
    ; format(atom(ErrorMsg), 'Hotel ~w does not exist in ~w', [OldHotelName, City]),
      throw(error(invalid_hotel, context(ErrorMsg)))
    ),
    ( number(NewPrice), NewPrice > 0 ->
        true
    ; throw(error(invalid_price, context('New price must be a positive number')))
    ),
    ( OldHotelName == NewHotelName ; \+ hotel(_, NewHotelName, _, _, _) -> % Allow updating price for the same name
        true
    ; format(atom(ErrorMsg), 'Hotel name ~w is already in use', [NewHotelName]),
      throw(error(duplicate_hotel, context(ErrorMsg)))
    ),
    retract(hotel(City, OldHotelName, OldPrice, OldRating, OldDemand)),
    assertz(hotel(City, NewHotelName, NewPrice, OldRating, OldDemand)), % Use old rating and demand
    format('Hotel ~w in ~w updated to ~w (~w EGP/night) by ~w~n', [OldHotelName, City, NewHotelName, NewPrice, UserID]).

% validate_inputs(+DurationDays, +MaxHoursPerDay, +GroupSize, +MinBudget, +MaxBudget)
% Validates inputs (internal check).
validate_inputs(DurationDays, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget) :-
    ( integer(DurationDays), DurationDays > 0 -> true ; throw(error(invalid_duration_days, context('DurationDays must be a positive integer')))),
    ( daily_time_constraint(MaxHoursPerDay) -> true ; throw(error(invalid_max_hours, context('MaxHoursPerDay must be 4, 6, 8, or 10')))),
    ( integer(GroupSize), GroupSize > 0 -> true ; throw(error(invalid_group_size, context('GroupSize must be positive integer')))),
    ( number(MinBudget), MinBudget >= 0 -> true ; throw(error(invalid_min_budget, context('MinBudget must be non-negative')))),
    ( number(MaxBudget), MaxBudget >= MinBudget -> true ; throw(error(invalid_max_budget, context('MaxBudget must be greater than or equal to MinBudget')))).

% check_season(+City, +Month, -Season)
% Checks travel suitability based on predefined best seasons.
check_season(City, Month, Season) :-
    month_to_number(Month, _Number), % Fails if Month is invalid
    season(Month, Season),
    ( city(City, Season, _Currency) ->
        true % It's a good season
    ;   format('Warning: ~w might not be the best season for ~w. Recommended seasons are: ', [Month, City]),
        findall(S, city(City, S, _), RecommendedSeasons),
        atomic_list_concat(RecommendedSeasons, ', ', RecStr),
        format('~w.~n', [RecStr]) % Allow planning but warn
    ).

% select_hotel(+City, +DurationDays, +MinBudget, +MaxBudget, -HotelName, -PricePerNight, -Rating)
% Selects a hotel within budget, prioritizing rating then price.
select_hotel(City, DurationDays, MinBudget, MaxBudget, HotelName, PricePerNight, Rating) :-
    MinHotelBudget is MinBudget * 0.20, % Min 20% of total min budget for hotel
    MaxHotelBudget is MaxBudget * 0.35, % Max 35% of total max budget for hotel
    findall(AvgReviewRating-Price-HotelRating-Hotel, (
        hotel(City, Hotel, Price, HotelRating, _),
        number(Price), Price > 0,
        TotalHotelCost is Price * DurationDays,
        TotalHotelCost =< MaxHotelBudget,
        TotalHotelCost >= MinHotelBudget,
        findall(ReviewRating, hotel_review(Hotel, ReviewRating, _), ReviewRatings),
        ( ReviewRatings = [] -> AvgReviewRating is HotelRating ; % Use base rating if no reviews
          sum_list(ReviewRatings, Sum), length(ReviewRatings, Len), AvgReviewRating is Sum / Len
        )
    ), Hotels),
    ( Hotels = [] ->
        format(atom(ErrorMsg), 'No hotels available in ~w within budget range for hotel (~1f - ~1f EGP for ~w days)',
               [City, MinHotelBudget, MaxHotelBudget, DurationDays]),
        throw(error(no_hotels_available, context(ErrorMsg)))
    ; true
    ),
    sort(1, @>=, Hotels, SortedByAvgRating), % Sort by AvgReviewRating (descending)
    sort(2, @=<, SortedByAvgRating, SortedHotels), % Then sort by Price (ascending)
    SortedHotels = [BestAvgRating-PricePerNight-Rating-HotelName | _], % Select the best
    number(PricePerNight), number(Rating), number(BestAvgRating), % Ensure numeric
    !.

% select_transport(+City, -TransportMode, -TransportCost)
% Selects cheapest transport.
select_transport(City, TransportMode, TransportCost) :-
    findall(Cost-Mode, (
        transport(City, Mode, Cost, _, _),
        number(Cost), Cost >= 0 % Ensure numeric and non-negative cost
    ), Transports),
    ( Transports = [] ->
        format(atom(ErrorMsg), 'No transport available in ~w', [City]),
        throw(error(no_transport_available, context(ErrorMsg)))
    ; true
    ),
    sort(1, @=<, Transports, [TransportCost-TransportMode|_]), % Sort by cost ascending, take first
    number(TransportCost). % Ensure numeric

% select_food_cost(+City, +MinBudget, +MaxBudget, -DailyFoodCost)
% Selects lowest food cost that potentially fits within budget.
select_food_cost(City, MinBudget, MaxBudget, DailyFoodCost) :-
    findall(Cost, (
        food_cost(City, Cost),
        number(Cost), Cost >= 0
    ), Costs),
    ( Costs = [] ->
        format(atom(ErrorMsg), 'No food costs defined for ~w', [City]),
        throw(error(no_food_costs, context(ErrorMsg)))
    ; true
    ),
    sort(Costs, SortedCosts), % Sort ascending
    % Basic check: select the cheapest unless the budget is very high
    MidBudget is (MinBudget + MaxBudget) / 2,
    length(SortedCosts, NumLevels),
    ( NumLevels == 0 -> throw(error(no_food_costs, context(City))) ; true ), % Should not happen if Costs check passed
    ( NumLevels > 2 -> % If Low, Mid, High exist
        nth1(1, SortedCosts, LowCost),
        nth1(2, SortedCosts, MidCost),
        nth1(3, SortedCosts, HighCost),
        ( MidBudget > 8000 -> DailyFoodCost = HighCost % High budget -> high food cost
        ; MidBudget > 4000 -> DailyFoodCost = MidCost % Mid budget -> mid food cost
        ; DailyFoodCost = LowCost % Default to lowest
        )
    ; NumLevels == 2 -> % Only Low, Mid (or similar)
        nth1(1, SortedCosts, LowCost),
        nth1(2, SortedCosts, HighCost), % Treat second as 'high'
        ( MidBudget > 5000 -> DailyFoodCost = HighCost
        ; DailyFoodCost = LowCost
        )
    ; NumLevels == 1 -> % Only one option
        SortedCosts = [DailyFoodCost|_]
    ).


% collect_all_activities(+City, -ActivitiesRaw)
% Collects all activities in the city as Cost-Duration-Name tuples.
collect_all_activities(City, ActivitiesRaw) :-
    findall(Cost-Duration-Activity, (
        activity(City, Activity, Cost, Duration, _Category, _Suitability),
        number(Cost), Cost >= 0, % Ensure numeric cost
        number(Duration), Duration > 0 % Ensure numeric duration
    ), ActivitiesRaw),
    ( ActivitiesRaw = [] ->
        format(atom(ErrorMsg), 'No activities available in ~w', [City]),
        throw(error(no_activities_available, context(ErrorMsg)))
    ; true
    ).

% distribute_activities(+DurationDays, +MaxHoursPerDay, +MaxBudget, +MinBudget, +PricePerNight, +DailyFoodCost, +TransportCost, +AllActivitiesRaw,
%                      -DailyActivitiesRaw, -ActivityCosts, -DailyActivityDetails)
% Distributes activities across days, respecting time and budget.
distribute_activities(DurationDays, MaxHoursPerDay, MaxBudget, MinBudget, PricePerNight, DailyFoodCost, TransportCost, AllActivitiesRaw,
                      DailyActivitiesRaw, ActivityCosts, DailyActivityDetails) :-

    % Calculate fixed costs
    ( number(PricePerNight), number(DailyFoodCost), number(TransportCost), integer(DurationDays) ->
        TotalFixedCost is PricePerNight * DurationDays + DailyFoodCost * DurationDays + TransportCost,
        % Budget remaining for activities
        MaxActivityBudget is max(0, MaxBudget - TotalFixedCost), % Ensure non-negative
        MinActivityBudget is max(0, MinBudget - TotalFixedCost), % Ensure non-negative

        % Average daily budget for activities
        AvgMaxDailyActivityCost is MaxActivityBudget / DurationDays,
        AvgMinDailyActivityCost is MinActivityBudget / DurationDays,

        % Distribute activities trying to balance cost and time
        sort(1, @=<, AllActivitiesRaw, SortedActivitiesByCost), % Sort by cost ascending for selection
        distribute_activities_by_day(DurationDays, MaxHoursPerDay, AvgMaxDailyActivityCost, AvgMinDailyActivityCost, SortedActivitiesByCost,
                                     [], [], [], DailyActivitiesRawRev, ActivityCostsRev, DailyActivityDetailsRev),

        % Reverse lists to get correct day order
        reverse(DailyActivitiesRawRev, DailyActivitiesRaw),
        reverse(ActivityCostsRev, ActivityCosts),
        reverse(DailyActivityDetailsRev, DailyActivityDetails)

    ;   format(atom(ErrorMsg), 'Invalid input to distribute_activities: PricePerNight=~w, DailyFoodCost=~w, TransportCost=~w, DurationDays=~w', [PricePerNight, DailyFoodCost, TransportCost, DurationDays]),
        throw(error(invalid_input, context(ErrorMsg)))
    ).

% distribute_activities_by_day(+DaysLeft, +MaxHoursPerDay, +AvgMaxDailyCost, +AvgMinDailyCost, +AvailableActivities,
%                              +AccActivitiesRaw, +AccCosts, +AccDetails, -FinalActivitiesRaw, -FinalCosts, -FinalDetails)
% Recursive helper for activity distribution.
distribute_activities_by_day(0, _, _, _, _, AccActivitiesRaw, AccCosts, AccDetails, AccActivitiesRaw, AccCosts, AccDetails). % Base case

distribute_activities_by_day(DaysLeft, MaxHoursPerDay, AvgMaxDailyCost, AvgMinDailyCost, AvailableActivities,
                             AccActivitiesRaw, AccCosts, AccDetails, FinalActivitiesRaw, FinalCosts, FinalDetails) :-
    DaysLeft > 0,
    % Select activities for the current day
    select_daily_activities(AvailableActivities, MaxHoursPerDay, AvgMaxDailyCost, AvgMinDailyCost,
                            DayActivitiesRaw, DayCost, DayDetails),

    % Update remaining activities (subtract selected ones)
    subtract(AvailableActivities, DayActivitiesRaw, RemainingActivities),

    % Recurse for the next day
    NextDaysLeft is DaysLeft - 1,
    distribute_activities_by_day(NextDaysLeft, MaxHoursPerDay, AvgMaxDailyCost, AvgMinDailyCost, RemainingActivities,
                                 [DayActivitiesRaw | AccActivitiesRaw], [DayCost | AccCosts], [DayDetails | AccDetails],
                                 FinalActivitiesRaw, FinalCosts, FinalDetails).

% select_daily_activities(+AvailableActivities, +MaxHours, +MaxCost, +MinCost, -SelectedActivitiesRaw, -TotalCost, -SelectedDetails)
% Selects activities for one day within constraints. Prioritizes fitting within MaxHours and MaxCost.
select_daily_activities(AvailableActivities, MaxHours, MaxCost, MinCost, SelectedActivitiesRaw, TotalCost, SelectedDetails) :-
    % Use greedy approach: pick cheapest first until limits hit.
    select_activities_greedy(AvailableActivities, MaxHours, MaxCost, [], 0, 0, SelectedActivitiesRev, TotalCost, _TotalHours),
    reverse(SelectedActivitiesRev, SelectedActivitiesRaw), % Correct order
    % Ensure minimum cost is met if possible, otherwise it's okay if TotalCost is 0
    ( TotalCost >= MinCost -> true ; true ), % Accept if below MinCost, including 0
    % Extract details (ensure this handles the empty list case correctly)
    ( SelectedActivitiesRaw == [] -> SelectedDetails = []
    ; maplist(extract_activity_details_tuple, SelectedActivitiesRaw, SelectedDetails) % Use tuple helper
    ),
    !. % Commit to the first solution found by greedy

% If greedy finds nothing, return empty lists
select_daily_activities(_, _, _, _, [], 0, []) :-
    format('Warning: No activities selected for a day. Constraints might be too tight.~n').


% select_activities_greedy(+Activities, +MaxH, +MaxC, +Acc, +AccH, +AccC, -Selected, -TotalC, -TotalH)
% Greedily selects cheapest activities that fit time and cost constraints.
select_activities_greedy([], _MaxH, _MaxC, Acc, AccH, AccC, Acc, AccC, AccH). % Base case: no more activities
select_activities_greedy([Cost-Duration-Name | Rest], MaxH, MaxC, Acc, AccH, AccC, Selected, TotalC, TotalH) :-
    NewH is AccH + Duration,
    NewC is AccC + Cost,
    ( NewH =< MaxH, NewC =< MaxC -> % If it fits
        select_activities_greedy(Rest, MaxH, MaxC, [Cost-Duration-Name | Acc], NewH, NewC, Selected, TotalC, TotalH)
    ; % If it doesn't fit, skip it and try the rest
        select_activities_greedy(Rest, MaxH, MaxC, Acc, AccH, AccC, Selected, TotalC, TotalH)
    ).

% extract_activity_details_tuple(+ActivityTupleRaw, -DetailsTuple)
% Extracts details into the Name-Cost-Duration format for printing.
extract_activity_details_tuple(Cost-Duration-ActivityName, ActivityName-Cost-Duration).

% extract_activity_name(+ActivityTupleRaw, -ActivityName)
% Extracts just the name from a Cost-Duration-Name tuple.
extract_activity_name(_Cost-_Duration-ActivityName, ActivityName).


% calculate_total_cost(+DurationDays, +PricePerNight, +DailyFoodCost, +TransportCost, +ActivityCosts, -TotalBudget)
% Calculates total cost, handling empty ActivityCosts.
calculate_total_cost(DurationDays, PricePerNight, DailyFoodCost, TransportCost, ActivityCosts, TotalBudget) :-
    TotalHotelCost is PricePerNight * DurationDays,
    TotalFoodCost is DailyFoodCost * DurationDays,
    ( ActivityCosts = [] -> TotalActivityCost = 0 ; sum_list(ActivityCosts, TotalActivityCost) ),
    TotalBudget is TotalHotelCost + TotalActivityCost + TransportCost + TotalFoodCost.

% check_budget(+TotalBudget, +MaxBudget, +MinBudget, -BudgetStatus)
% Checks budget and sets status. Uses 80% of MinBudget as a soft lower bound for 'ok'.
check_budget(TotalBudget, MaxBudget, MinBudget, ok) :-
    TotalBudget =< MaxBudget,
    TotalBudget >= MinBudget * 0.8, % Allow slightly under MinBudget
    !.
check_budget(TotalBudget, MaxBudget, MinBudget, over) :-
    TotalBudget > MaxBudget,
    format(atom(ErrorMsg), 'Total budget ~w EGP exceeds maximum budget ~w EGP (MinBudget: ~w EGP)', [TotalBudget, MaxBudget, MinBudget]),
    throw(error(budget_out_of_range, context(ErrorMsg))).
check_budget(TotalBudget, MaxBudget, MinBudget, under) :-
    TotalBudget < MinBudget * 0.8, % Definitely under the desired minimum
    format('Warning: Total budget ~w EGP is significantly below minimum desired budget ~w EGP (MaxBudget: ~w EGP).~n', [TotalBudget, MinBudget, MaxBudget]),
    !. % Succeed, but the status is 'under' for advice


% --- Printing Predicates ---

% print_travel_plan(+UserID, +City, +DurationDays, +GroupSize, +HotelName, +Rating, +TransportMode, +TransportCost
%                  +DailyActivities, +TotalBudget, +PricePerNight, +ActivityCosts, +DailyFoodCost,
%                  +DailyActivityDetails, +BudgetStatus, +AllActivitiesRaw, +MinBudget, +MaxBudget)
% Prints the final travel plan in the desired format.
print_travel_plan(UserID, City, DurationDays, GroupSize, HotelName, Rating, TransportMode, TransportCost,
                 DailyActivities, TotalBudget, PricePerNight, ActivityCosts, DailyFoodCost, DailyActivityDetails, BudgetStatus, AllActivitiesRaw, MinBudget, MaxBudget) :-
    format('~n=== TRAVEL PLAN FOR ~w ===~n', [UserID]),
    format('  Destination: ~w~n', [City]),
    format('  Duration: ~w days~n', [DurationDays]),
    format('  Group Size: ~w~n~n', [GroupSize]),

    format('=== RECOMMENDATIONS ===~n'),
    format('  Selected Hotel: ~w (Rating: ~1f)~n', [HotelName, Rating]),
    print_other_hotels(City, HotelName, DurationDays, TotalBudget), % Pass TotalBudget for context

    format('  Selected Transport: ~w (Cost: ~w EGP)~n', [TransportMode, TransportCost]),
    print_other_transports(City, TransportMode),

    format('  Selected Activities:~n'),
    ( flatten(DailyActivities, FlatActivities), FlatActivities \= [] -> % Check if any activities were selected across all days
        print_selected_activities(DailyActivities, DailyActivityDetails, 1)
    ; format('    No activities selected (check budget/time constraints).~n')
    ),

    print_other_activities(AllActivitiesRaw, DailyActivities, City),
    print_associated_attractions(DailyActivities, City),

    format('~n=== COST ESTIMATE ===~n'),
    TotalHotelCost is PricePerNight * DurationDays,
    TotalFoodCost is DailyFoodCost * DurationDays,
    ( ActivityCosts = [] -> TotalActivityCost = 0 ; sum_list(ActivityCosts, TotalActivityCost) ),
    format('  Hotel: ~w EGP~n', [TotalHotelCost]),
    format('  Activities: ~w EGP~n', [TotalActivityCost]),
    ( flatten(DailyActivities, FlatActivitiesCheck), FlatActivitiesCheck \= [] ->
        print_activity_cost_details(1, DailyActivities, DailyActivityDetails, ActivityCosts)
    ; format('    No activities planned.~n')
    ),
    format('  Transport: ~w EGP~n', [TransportCost]),
    format('    Selected: ~w (~w EGP/trip)~n', [TransportMode, TransportCost]),
    format('  Food: ~w EGP~n', [TotalFoodCost]),
    format('    Daily: ~w EGP (~w days)~n', [DailyFoodCost, DurationDays]),
    format('  TOTAL: ~w EGP~n~n', [TotalBudget]),

    format('=== DAILY ITINERARY ===~n'),
    ( flatten(DailyActivities, FlatItinCheck), FlatItinCheck \= [] ->
        print_daily_itinerary(1, DailyActivities, HotelName, TransportMode, DailyActivityDetails)
    ; format('  No itinerary planned due to lack of activities.~n')
    ),

    format('Plan saved successfully for ~w.~n', [UserID]),

    format('~n=== BUDGET ADVICE ===~n'),
    provide_budget_advice(BudgetStatus, TotalBudget, MinBudget, MaxBudget).


% print_other_hotels(+City, +SelectedHotel, +DurationDays, +TotalBudget)
% Prints up to 2 alternative hotels, cheaper first.
print_other_hotels(City, SelectedHotel, DurationDays, TotalBudget) :-
    % Find hotels cheaper than selected, or slightly more expensive if budget allows
    MaxHotelBudget is TotalBudget * 0.40, % Allow slightly higher budget for alternatives
    findall(Price-Hotel-Rating, (
        hotel(City, Hotel, Price, BaseRating, _),
        Hotel \= SelectedHotel,
        number(Price), Price > 0,
        TotalHotelCost is Price * DurationDays,
        TotalHotelCost =< MaxHotelBudget, % Check against slightly higher budget
        findall(RevRate, hotel_review(Hotel, RevRate, _), RevRates),
        ( RevRates=[] -> Rating = BaseRating ; sum_list(RevRates, Sum), length(RevRates, Len), Rating is Sum/Len )
    ), OtherHotels),
    sort(1, @=<, OtherHotels, SortedOtherHotels), % Sort by Price Ascending
    ( SortedOtherHotels \= [] ->
        format('  Other Hotels:~n'),
        print_other_hotels_list(SortedOtherHotels, 0, 2) % Print max 2
    ; format('  Other Hotels: None available meeting criteria~n')
    ).

print_other_hotels_list([], _, _) :- !.
print_other_hotels_list(_, Count, MaxCount) :- Count >= MaxCount, !.
print_other_hotels_list([Price-Hotel-Rating | Rest], Count, MaxCount) :-
    format('    ~w: ~w EGP/night, Rating: ~1f~n', [Hotel, Price, Rating]),
    NextCount is Count + 1,
    print_other_hotels_list(Rest, NextCount, MaxCount).


% print_other_transports(+City, +SelectedMode)
% Prints alternative transports, sorted by cost.
print_other_transports(City, SelectedMode) :-
    findall(Cost-Mode, (
        transport(City, Mode, Cost, _, _),
        Mode \= SelectedMode,
        number(Cost), Cost >= 0
    ), OtherTransports),
    sort(1, @=<, OtherTransports, SortedOtherTransports), % Sort by Cost Ascending
    ( SortedOtherTransports \= [] ->
        format('  Other Transports:~n'),
        print_other_transports_list(SortedOtherTransports)
    ; format('  Other Transports: None available~n')
    ).

print_other_transports_list([]) :- !.
print_other_transports_list([Cost-Mode | Rest]) :-
    format('    ~w: ~w EGP/trip~n', [Mode, Cost]),
    print_other_transports_list(Rest).


% print_selected_activities(+DailyActivities, +DailyActivityDetails, +DayNum)
% Prints selected activities grouped by day.
print_selected_activities([], [], _) :- !.
print_selected_activities([Activities | RestActivities], [Details | RestDetails], DayNum) :-
    ( Activities \= [] -> % Only print day header if there are activities for the day
        format('    Day ~w:~n', [DayNum]),
        print_day_activity_details(Activities, Details) % Use helper
    ; true % Skip day if no activities
    ),
    NextDay is DayNum + 1,
    print_selected_activities(RestActivities, RestDetails, NextDay).


% print_other_activities(+AllActivitiesRaw, +SelectedDailyActivities, +City)
% Prints activities that were not selected.
print_other_activities(AllActivitiesRaw, SelectedDailyActivities, City) :-
    flatten(SelectedDailyActivities, FlatSelectedNames), % Get a flat list of selected activity names
    findall(Cost-Duration-Name, (
        member(Cost-Duration-Name, AllActivitiesRaw),
        \+ member(Name, FlatSelectedNames) % Check if the Name is NOT in the selected list
    ), UnselectedActivitiesRaw),
    sort(1, @=<, UnselectedActivitiesRaw, SortedUnselected), % Sort by cost ascending
    ( SortedUnselected \= [] ->
        format('  Other Activities:~n'),
        print_other_activities_list(SortedUnselected, City)
    ; format('  Other Activities: All available activities were selected or none matched criteria.~n')
    ).

print_other_activities_list([], _) :- !.
print_other_activities_list([Cost-Duration-Activity | Rest], City) :-
    ( activity_attraction_link(Activity, AttractionName) -> % Find linked attraction
        true
    ; AttractionName = 'None' % Default if no link defined
    ),
    format('    ~w: ~w EGP, ~1f hours (Attraction: ~w)~n', [Activity, Cost, Duration, AttractionName]),
    print_other_activities_list(Rest, City).


% print_associated_attractions(+DailyActivities, +City)
% Prints attraction details linked to selected activities. Uses set to avoid duplicates.
print_associated_attractions(DailyActivities, City) :-
    flatten(DailyActivities, FlatSelectedActivities),
    list_to_set(FlatSelectedActivities, UniqueSelectedActivities), % Avoid duplicate attraction printing
    ( UniqueSelectedActivities \= [] ->
        format('  Associated Attractions:~n'),
        print_attraction_details_list(UniqueSelectedActivities, City)
    ; format('  Associated Attractions: No activities with linked attractions selected.~n')
    ).

print_attraction_details_list([], _) :- !.
print_attraction_details_list([Activity | Rest], City) :-
    (   activity_attraction_link(Activity, AttractionName), % Find the linked attraction name
        attraction(City, AttractionName, Type, [Open, Close]) % Get details
    ->  format('    ~w (~w): Open ~w:00 - ~w:00~n', [Activity, Type, Open, Close])
    ;   true % Silently skip if no link or details
    ),
    print_attraction_details_list(Rest, City).


% print_activity_cost_details(+DayIndex, +DailyActivities, +DailyActivityDetails, +ActivityCosts)
% Prints activity cost breakdown per day.
print_activity_cost_details(_, [], [], []) :- !.
print_activity_cost_details(DayIndex, [DayActivities|RestActivities], [DayDetails|RestDetails], [DayCost|RestCosts]) :-
    ( DayActivities \= [] -> % Only print if there are activities/cost for the day
        format('    Day ~w: ~w EGP~n', [DayIndex, DayCost]),
        print_day_activity_details(DayActivities, DayDetails) % Use helper
    ; true
    ),
    NextDayIndex is DayIndex + 1,
    print_activity_cost_details(NextDayIndex, RestActivities, RestDetails, RestCosts).

% print_day_activity_details(+DayActivityNames, +DayActivityDetailsTuples)
% Helper to print details for a single day's activities (Name: Cost EGP, Duration hours).
% Handles potential empty lists.
print_day_activity_details([], []) :- !. % Base case: Both empty is fine.
print_day_activity_details([ActivityName | RestNames], [ActivityName-Cost-Duration | RestDetails]) :- % Match name for safety
    !, % Cut if match succeeds
    format('      ~w: ~w EGP, ~1f hours~n', [ActivityName, Cost, Duration]),
    print_day_activity_details(RestNames, RestDetails).
print_day_activity_details(Names, Details) :- % Catch mismatch or error
    format('      Error printing activity details (mismatch between names: ~w and details: ~w).~n', [Names, Details]).


% print_daily_itinerary(+DayNum, +DailyActivities, +HotelName, +TransportMode, +DailyActivityDetails)
% Prints the day-by-day itinerary.
print_daily_itinerary(_, [], _, _, []) :- !. % Base case: End of days, DO NOT print separator here.
print_daily_itinerary(DayNum, [Activities|RestActivities], HotelName, TransportMode, [DayDetails|RestDetails]) :-
    format('  DAY ~w:~n', [DayNum]),
    format('    Hotel: ~w~n', [HotelName]),
    format('    Transport: ~w~n', [TransportMode]),
    ( Activities \= [] -> % Check if the list for THIS day is empty
        format('    Activities:~n'),
        print_itinerary_day_activities(Activities, DayDetails) % Use helper
    ; format('    Activities: None planned for this day.~n')
    ),
    format('  ---~n'), % Separator between days
    NextDay is DayNum + 1,
    print_daily_itinerary(NextDay, RestActivities, HotelName, TransportMode, RestDetails).

% print_itinerary_day_activities(+ActivityNames, +DayDetailsTuples)
% Helper to print activity names and durations for the itinerary. Robust to empty lists.
print_itinerary_day_activities([], []) :- !. % Base case: Both empty is fine.
print_itinerary_day_activities([ActivityName | RestNames], [ActivityName-_-Duration | RestDetails]) :- % Match name, ignore cost
    !, % Cut if match succeeds
    format('      ~w: ~1f hours~n', [ActivityName, Duration]),
    print_itinerary_day_activities(RestNames, RestDetails).
print_itinerary_day_activities(Names, Details) :- % Catch mismatch or error
     format('      Error printing itinerary activities (mismatch between names: ~w and details: ~w).~n', [Names, Details]).


% provide_budget_advice(+BudgetStatus, +TotalBudget, +MinBudget, +MaxBudget)
% Provides tailored budget advice based on the status.
provide_budget_advice(ok, TotalBudget, _, MaxBudget) :- % MaxBudget used
    Remaining is MaxBudget - TotalBudget,
    format('  Your plan costs ~w EGP, leaving ~w EGP within your max budget for flexibility or upgrades.~n', [TotalBudget, Remaining]),
    ( Remaining > 500 -> % Suggest if there's significant room
      format('  Consider upgrading the hotel, adding premium activities, or enjoying finer dining.~n')
    ; format('  The budget is well-utilized.~n')
    ).
provide_budget_advice(over, TotalBudget, MinBudget, MaxBudget) :- % Both MinBudget and MaxBudget used
    Exceeded is TotalBudget - MaxBudget,
    format('  Advice: The plan exceeds your max budget by ~w EGP (~w EGP > ~w EGP). Your range was ~w - ~w EGP. Consider:~n', [Exceeded, TotalBudget, MaxBudget, MinBudget, MaxBudget]),
    format('    - Choosing a cheaper hotel (e.g., check "Other Hotels" recommendations).~n'),
    format('    - Reducing the number of activities or selecting lower-cost options (e.g., < 200 EGP).~n'),
    format('    - Opting for the cheapest transport method available (e.g., Metro/Bus).~n'),
    format('    - Lowering the daily food budget allocation.~n'),
    format('    - Alternatively, increase your MaxBudget to at least ~w EGP.~n', [TotalBudget]).
provide_budget_advice(under, TotalBudget, MinBudget, MaxBudget) :- % Both MinBudget and MaxBudget used
    Shortfall is MinBudget - TotalBudget, % Calculate difference from minimum desired
    format('  Advice: The plan is ~w EGP below your desired minimum budget (~w EGP < ~w EGP). Your range was ~w - ~w EGP. Consider:~n', [Shortfall, TotalBudget, MinBudget, MinBudget, MaxBudget]),
    format('    - Adding more activities, especially higher-cost unique experiences (e.g., > 400 EGP).~n'),
    format('    - Upgrading to a higher-rated or better-located hotel (check recommendations).~n'),
    format('    - Allocating a higher daily budget for food and local experiences.~n'),
    format('    - Alternatively, lower your MinBudget if you are satisfied with this plan.~n').


% Example Usage:
% ?- start_planner.

% ?- submit_hotel_review('Omar', 'Hilton Cairo Nile', 5.0, 'Absolutely perfect stay!').
% ?- update_hotel('Admin', 'Cairo', 'Economy Hotel Cairo', 'Super Economy Cairo', 550).
