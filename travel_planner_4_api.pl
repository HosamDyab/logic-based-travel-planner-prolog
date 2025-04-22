% travel_planner_4_api.pl
% A Prolog-based travel planner - Modified for API interaction

:- module(travel_planner_4_api, [
    plan_trip_api/9,        % Returns plan or error dict
    submit_hotel_review_api/5, % Returns status dict
    update_hotel_api/6,     % Returns status dict
    get_hotel_reviews_api/2 % New: Get reviews for a hotel
]).

% --- Keep all your original imports, dynamic declarations, and facts ---
:- use_module(library(lists), [member/2, subtract/3, sum_list/2, reverse/2, flatten/2, nth1/3, list_to_set/2]).
:- use_module(library(apply), [maplist/3, maplist/4]).
% :- use_module(library(readutil), [read_line_to_string/2]). % Not needed for API

:- dynamic(hotel/5).
:- dynamic(hotel_review/3).

% --- Facts ---
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

% --- Helper predicates and rules ---
% Validation
validate_inputs(DurationDays, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget) :-
    ( integer(DurationDays), DurationDays > 0 -> true ; throw(error(invalid_duration_days, context('DurationDays must be a positive integer')))),
    ( daily_time_constraint(MaxHoursPerDay) -> true ; throw(error(invalid_max_hours, context('MaxHoursPerDay must be 4, 6, 8, or 10')))),
    ( integer(GroupSize), GroupSize > 0 -> true ; throw(error(invalid_group_size, context('GroupSize must be positive integer')))),
    ( number(MinBudget), MinBudget >= 0 -> true ; throw(error(invalid_min_budget, context('MinBudget must be non-negative')))),
    ( number(MaxBudget), MaxBudget >= MinBudget -> true ; throw(error(invalid_max_budget, context('MaxBudget must be greater than or equal to MinBudget')))).

check_season(City, Month, Season) :-
    month_to_number(Month, _Number), % Fails if Month is invalid
    season(Month, Season),
    ( city(City, Season, _Currency) ->
        true % It's a good season
    ;   format(string(Warning), 'Warning: ~w might not be the best season for ~w. Recommended seasons are: ', [Month, City]),
        findall(S, city(City, S, _), RecommendedSeasons),
        atomic_list_concat(RecommendedSeasons, ', ', RecStr),
        format(string(_), '~w~w.~n', [Warning, RecStr]),
        true % Allow planning but warn
    ).

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
        format(string(ErrorMsg), 'No hotels available in ~w within budget range for hotel (~1f - ~1f EGP for ~w days)',
               [City, MinHotelBudget, MaxHotelBudget, DurationDays]),
        throw(error(no_hotels_available, context(ErrorMsg))) % Keep throwing errors
    ; true
    ),
    sort(1, @>=, Hotels, SortedByAvgRating), % Sort by AvgReviewRating (descending)
    sort(2, @=<, SortedByAvgRating, SortedHotels), % Then sort by Price (ascending)
    SortedHotels = [BestAvgRating-PricePerNight-Rating-HotelName | _], % Select the best
    number(PricePerNight), number(Rating), number(BestAvgRating), % Ensure numeric
    !.

select_transport(City, TransportMode, TransportCost) :-
    findall(Cost-Mode, (
        transport(City, Mode, Cost, _, _),
        number(Cost), Cost >= 0 % Ensure numeric and non-negative cost
    ), Transports),
    ( Transports = [] ->
        format(string(ErrorMsg), 'No transport available in ~w', [City]),
        throw(error(no_transport_available, context(ErrorMsg)))
    ; true
    ),
    sort(1, @=<, Transports, [TransportCost-TransportMode|_]), % Sort by cost ascending, take first
    number(TransportCost). % Ensure numeric

select_food_cost(City, MinBudget, MaxBudget, DailyFoodCost) :-
    findall(Cost, (
        food_cost(City, Cost),
        number(Cost), Cost >= 0
    ), Costs),
    ( Costs = [] ->
        format(string(ErrorMsg), 'No food costs defined for ~w', [City]),
        throw(error(no_food_costs, context(ErrorMsg)))
    ; true
    ),
    sort(Costs, SortedCosts), % Sort ascending
    MidBudget is (MinBudget + MaxBudget) / 2,
    length(SortedCosts, NumLevels),
    ( NumLevels == 0 -> throw(error(no_food_costs, context(City))) ; true ),
    ( NumLevels > 2 ->
        nth1(1, SortedCosts, LowCost),
        nth1(2, SortedCosts, MidCost),
        nth1(3, SortedCosts, HighCost),
        ( MidBudget > 8000 -> DailyFoodCost = HighCost
        ; MidBudget > 4000 -> DailyFoodCost = MidCost
        ; DailyFoodCost = LowCost
        )
    ; NumLevels == 2 ->
        nth1(1, SortedCosts, LowCost),
        nth1(2, SortedCosts, HighCost),
        ( MidBudget > 5000 -> DailyFoodCost = HighCost
        ; DailyFoodCost = LowCost
        )
    ; NumLevels == 1 ->
        SortedCosts = [DailyFoodCost|_]
    ).

collect_all_activities(City, ActivitiesRaw) :-
    findall(Cost-Duration-Activity, (
        activity(City, Activity, Cost, Duration, _Category, _Suitability),
        number(Cost), Cost >= 0, % Ensure numeric cost
        number(Duration), Duration > 0 % Ensure numeric duration
    ), ActivitiesRaw),
    ( ActivitiesRaw = [] ->
        true
    ; true
    ).

distribute_activities(DurationDays, MaxHoursPerDay, MaxBudget, MinBudget, PricePerNight, DailyFoodCost, TransportCost, AllActivitiesRaw,
                      DailyActivitiesRaw, ActivityCosts, DailyActivityDetails) :-
    ( number(PricePerNight), number(DailyFoodCost), number(TransportCost), integer(DurationDays) ->
        TotalFixedCost is PricePerNight * DurationDays + DailyFoodCost * DurationDays + TransportCost,
        MaxActivityBudget is max(0, MaxBudget - TotalFixedCost),
        MinActivityBudget is max(0, MinBudget - TotalFixedCost),
        AvgMaxDailyActivityCost is MaxActivityBudget / DurationDays,
        AvgMinDailyActivityCost is MinActivityBudget / DurationDays,

        sort(1, @=<, AllActivitiesRaw, SortedActivitiesByCost),
        distribute_activities_by_day(DurationDays, MaxHoursPerDay, AvgMaxDailyActivityCost, AvgMinDailyActivityCost, SortedActivitiesByCost,
                                     [], [], [], DailyActivitiesRawRev, ActivityCostsRev, DailyActivityDetailsRev),

        reverse(DailyActivitiesRawRev, DailyActivitiesRaw),
        reverse(ActivityCostsRev, ActivityCosts),
        reverse(DailyActivityDetailsRev, DailyActivityDetails)

    ;   format(string(ErrorMsg), 'Internal Error: Invalid input to distribute_activities: PricePerNight=~w, DailyFoodCost=~w, TransportCost=~w, DurationDays=~w', [PricePerNight, DailyFoodCost, TransportCost, DurationDays]),
        throw(error(internal_error, context(ErrorMsg)))
    ).

distribute_activities_by_day(0, _, _, _, _, AccActivitiesRaw, AccCosts, AccDetails, AccActivitiesRaw, AccCosts, AccDetails). % Base case
distribute_activities_by_day(DaysLeft, MaxHoursPerDay, AvgMaxDailyCost, AvgMinDailyCost, AvailableActivities,
                             AccActivitiesRaw, AccCosts, AccDetails, FinalActivitiesRaw, FinalCosts, FinalDetails) :-
    DaysLeft > 0,
    catch(
        select_daily_activities(AvailableActivities, MaxHoursPerDay, AvgMaxDailyCost, AvgMinDailyCost,
                                DayActivitiesRaw, DayCost, DayDetails),
        error(no_activities_fit, _), % Catch specific error if select_daily fails gracefully
        (DayActivitiesRaw = [], DayCost = 0, DayDetails = []) % Assign empty if selection failed
    ),
    subtract(AvailableActivities, DayActivitiesRaw, RemainingActivities),
    NextDaysLeft is DaysLeft - 1,
    distribute_activities_by_day(NextDaysLeft, MaxHoursPerDay, AvgMaxDailyCost, AvgMinDailyCost, RemainingActivities,
                                 [DayActivitiesRaw | AccActivitiesRaw], [DayCost | AccCosts], [DayDetails | AccDetails],
                                 FinalActivitiesRaw, FinalCosts, FinalDetails).

select_daily_activities(AvailableActivities, MaxHours, MaxCost, MinCost, SelectedActivitiesRaw, TotalCost, SelectedDetails) :-
    select_activities_greedy(AvailableActivities, MaxHours, MaxCost, [], 0, 0, SelectedActivitiesRev, TotalCost, _TotalHours),
    ( SelectedActivitiesRev == [] -> % If greedy found nothing
        (AvailableActivities == [] -> % And there were no activities left
            SelectedActivitiesRaw = [], TotalCost = 0, SelectedDetails = [] % Return empty legitimately
        ; % There were activities, but none fit constraints
          throw(error(no_activities_fit, context('No available activities fit the daily time/cost constraints')))
        )
    ; % Greedy found some activities
        reverse(SelectedActivitiesRev, SelectedActivitiesRaw),
        ( TotalCost >= MinCost -> true ; true ), % Allow under minimum if that's all that fits
        maplist(extract_activity_details_tuple, SelectedActivitiesRaw, SelectedDetails)
    ),
    !. % Commit

select_activities_greedy([], _MaxH, _MaxC, Acc, AccH, AccC, Acc, AccC, AccH). % Base case: no more activities
select_activities_greedy([Cost-Duration-Name | Rest], MaxH, MaxC, Acc, AccH, AccC, Selected, TotalC, TotalH) :-
    NewH is AccH + Duration,
    NewC is AccC + Cost,
    ( NewH =< MaxH, NewC =< MaxC -> % If it fits
        select_activities_greedy(Rest, MaxH, MaxC, [Cost-Duration-Name | Acc], NewH, NewC, Selected, TotalC, TotalH)
    ; % If it doesn't fit, skip it and try the rest
        select_activities_greedy(Rest, MaxH, MaxC, Acc, AccH, AccC, Selected, TotalC, TotalH)
    ).

extract_activity_details_tuple(Cost-Duration-ActivityName, activity_detail{name:ActivityName, cost:Cost, duration:Duration}).

extract_activity_name(_Cost-_Duration-ActivityName, ActivityName).

calculate_total_cost(DurationDays, PricePerNight, DailyFoodCost, TransportCost, ActivityCosts, TotalBudget) :-
    TotalHotelCost is PricePerNight * DurationDays,
    TotalFoodCost is DailyFoodCost * DurationDays,
    ( ActivityCosts = [] -> TotalActivityCost = 0 ; sum_list(ActivityCosts, TotalActivityCost) ),
    TotalBudget is TotalHotelCost + TotalActivityCost + TransportCost + TotalFoodCost.

% check_budget modified to return status atom, not throw error here
check_budget(TotalBudget, MaxBudget, MinBudget, ok) :-
    TotalBudget =< MaxBudget,
    TotalBudget >= MinBudget * 0.8, % Allow slightly under MinBudget
    !.
check_budget(TotalBudget, MaxBudget, _MinBudget, over) :-
    TotalBudget > MaxBudget,
    !.
check_budget(TotalBudget, _MaxBudget, MinBudget, under) :-
    TotalBudget < MinBudget * 0.8,
    !.

% --- API Predicates ---
% plan_trip_api(UserID, City, DurationDays, Month, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget, PlanResultDict)
plan_trip_api(UserID, City, DurationDays, Month, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget, Result) :-
    catch(
        trip_planning(UserID, City, DurationDays, Month, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget, Result),
        Error,
        (extract_error_message(Error, ErrorMessage),
         Result = _{status: error, message: ErrorMessage})
    ).

% New helper predicate to handle the main planning logic
trip_planning(UserID, City, DurationDays, Month, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget, Result) :-
    validate_inputs(DurationDays, MaxHoursPerDay, GroupSize, MinBudget, MaxBudget),
    
    (member(City, ['Cairo', 'Aswan', 'PortSaid']) -> true
     ; format(string(EM), 'Invalid city: ~w. Choose Cairo, Aswan, or PortSaid.', [City]),
       throw(error(validation_error, context(EM)))),
    
    (month_to_number(Month, _) -> true
     ; format(string(EM), 'Invalid month name: ~w.', [Month]),
       throw(error(validation_error, context(EM)))),
    
    check_season(City, Month, _Season),
    
    select_hotel(City, DurationDays, MinBudget, MaxBudget, HotelName, PricePerNight, Rating),
    select_transport(City, TransportMode, TransportCost),
    select_food_cost(City, MinBudget, MaxBudget, DailyFoodCost),
    collect_all_activities(City, AllActivitiesRaw),
    
    distribute_activities(DurationDays, MaxHoursPerDay, MaxBudget, MinBudget, 
                         PricePerNight, DailyFoodCost, TransportCost, AllActivitiesRaw,
                         DailyActivitiesRaw, ActivityCosts, DailyActivityDetails),
    
    maplist(maplist(extract_activity_name), DailyActivitiesRaw, DailyActivities),
    
    calculate_total_cost(DurationDays, PricePerNight, DailyFoodCost, TransportCost, ActivityCosts, TotalBudget),
    check_budget(TotalBudget, MaxBudget, MinBudget, BudgetStatus),
    
    (BudgetStatus == over ->
        format(string(ErrorMsg), 'Budget exceeded: Total cost ~w EGP is over max budget ~w EGP.', [TotalBudget, MaxBudget]),
        throw(error(budget_error, context(ErrorMsg)))
    ; true),
    
    % Fixed approach for hotel recommendations - collect as price-hotel pairs for sorting
    findall(Price-HotelRec,
           (hotel(City, HName, HPrice, HRating, _),
            HName \= HotelName,
            TotalHCost is HPrice * DurationDays,
            TotalHCost =< MaxBudget * 0.40,
            HotelRec = hotel_rec{name:HName, price:HPrice, rating:HRating}),
           HotelPairs),
    
    % Sort by price (first element of the pair) and then extract just the hotel recs
    sort(1, @=<, HotelPairs, SortedHotelPairs),
    findall(HRec, member(_-HRec, SortedHotelPairs), SortedHotels),
    take(2, SortedHotels, OtherHotelRecs),
    
    % Simple structure with avoided nesting
    Result = _{
        status: success,
        user_id: UserID,
        city: City,
        duration: DurationDays,
        group_size: GroupSize, 
        month: Month,
        hotel: _{name: HotelName, rating: Rating, price_per_night: PricePerNight},
        transport: _{mode: TransportMode, cost: TransportCost},
        food: _{daily_cost: DailyFoodCost},
        daily_activities: DailyActivities,
        daily_details: DailyActivityDetails,
        daily_costs: ActivityCosts,
        total_budget: TotalBudget,
        budget_status: BudgetStatus,
        recommendations: _{other_hotels: OtherHotelRecs}
    }.

% Helper to extract a user-friendly message from Prolog error terms
extract_error_message(error(Formal, context(Context)), Message) :- !,
    ( Context = validation_error(Msg) -> Message = Msg
    ; Context = invalid_city(Msg) -> Message = Msg
    ; Context = invalid_month(Msg) -> Message = Msg
    ; Context = invalid_duration_days(Msg) -> Message = Msg
    ; Context = invalid_max_hours(Msg) -> Message = Msg
    ; Context = invalid_group_size(Msg) -> Message = Msg
    ; Context = invalid_min_budget(Msg) -> Message = Msg
    ; Context = invalid_max_budget(Msg) -> Message = Msg
    ; Context = no_hotels_available(Msg) -> Message = Msg
    ; Context = no_transport_available(Msg) -> Message = Msg
    ; Context = no_food_costs(Msg) -> Message = Msg
    ; Context = budget_error(Msg) -> Message = Msg
    ; Context = no_activities_fit(Msg) -> Message = Msg
    ; is_dict(Context) -> term_string(Context, Msg) , Message = Msg % Catch dict contexts
    ; atom_string(Context, Msg) -> Message = Msg % Catch atom contexts
    ; format(string(Msg), "Error: ~w (~w)", [Formal, Context]), Message = Msg % Fallback
    ).
extract_error_message(Error, Message) :- % Fallback for non-standard errors
    term_string(Error, Message).

% Helper for take/N (like Haskell's take)
take(N, List, Result) :- findall(X, (nth1(I, List, X), I =< N), Result).

% submit_hotel_review_api(UserID, HotelName, Rating, Comment, ResultDict)
submit_hotel_review_api(UserID, HotelName, Rating, Comment, ResultDict) :-
    catch(
        (   % Validation
            ( hotel(_, HotelName, _, _, _) -> true
            ; format(string(EM), 'Hotel "~w" does not exist.', [HotelName]),
              throw(error(validation_error, context(EM))) ),
            ( (number(Rating), Rating >= 0, Rating =< 5) -> true
            ; throw(error(validation_error, context('Rating must be a number between 0 and 5.'))) ),
            ( string_length(Comment, Len), Len > 0 -> true
            ; throw(error(validation_error, context('Comment cannot be empty.'))) ),

            % Action - use UserID to avoid warning
            format(string(_LogMsg), 'User ~w submitted review for ~w', [UserID, HotelName]),
            assertz(hotel_review(HotelName, Rating, Comment)),

            % Success Result
            ResultDict = _{status: success, message: 'Review submitted successfully.'}
        ),
        Error,
        % Error Result
        extract_error_message(Error, ErrorMessage),
        ResultDict = _{status: error, message: ErrorMessage}
    ).

% update_hotel_api(UserID, City, OldHotelName, NewHotelName, NewPrice, ResultDict)
update_hotel_api(UserID, City, OldHotelName, NewHotelName, NewPrice, ResultDict) :-
    catch(
        (   % Validation
            ( hotel(City, OldHotelName, OldPrice, OldRating, OldDemand) -> true
            ; format(string(EM), 'Hotel "~w" does not exist in city "~w".', [OldHotelName, City]),
              throw(error(validation_error, context(EM))) ),
            ( (number(NewPrice), NewPrice > 0) -> true
            ; throw(error(validation_error, context('New price must be a positive number.'))) ),
            ( (OldHotelName == NewHotelName ; \+ hotel(_, NewHotelName, _, _, _)) -> true
            ; format(string(EM), 'New hotel name "~w" is already in use.', [NewHotelName]),
              throw(error(validation_error, context(EM))) ),
             ( string_length(NewHotelName, Len), Len > 0 -> true
            ; throw(error(validation_error, context('New hotel name cannot be empty.'))) ),

            % Action
            retract(hotel(City, OldHotelName, OldPrice, OldRating, OldDemand)),
            assertz(hotel(City, NewHotelName, NewPrice, OldRating, OldDemand)), % Keep old rating/demand

             % Success Result
            format(string(Msg), 'Hotel ~w updated to ~w (~w EGP) in ~w by ~w.',
                   [OldHotelName, NewHotelName, NewPrice, City, UserID]), % UserID for context msg
            ResultDict = _{status: success, message: Msg}
        ),
        Error,
         % Error Result
        extract_error_message(Error, ErrorMessage),
        ResultDict = _{status: error, message: ErrorMessage}
    ).

% get_hotel_reviews_api(HotelName, ResultDict)
get_hotel_reviews_api(HotelName, ResultDict) :-
    catch(
        (   ( hotel(_, HotelName, _, _, _) -> true
            ; format(string(EM), 'Hotel "~w" does not exist.', [HotelName]),
              throw(error(validation_error, context(EM))) ),

            findall(review{rating: R, comment: C}, hotel_review(HotelName, R, C), Reviews),

            ResultDict = _{status: success, hotel: HotelName, reviews: Reviews}
        ),
        Error,
        extract_error_message(Error, ErrorMessage),
        ResultDict = _{status: error, message: ErrorMessage}
    ). 