//
//  Constants.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-22.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_Constants_h
#define GlucoGuide_Constants_h

#pragma mark - Device Detection

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPAD_PRO (IS_IPAD && SCREEN_MAX_LENGTH == 1366.0)

#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812)

#pragma mark - General && Commonly Used Strings

#import "LocalizationManager.h"

static NSString *const TIME_AM = @"AM";
static NSString *const TIME_PM = @"PM";
static NSString *const TIME_TODAY = @"Today";
static NSString *const TIME_THIS_WEEK = @"This Week";

static NSString *const MSG_YES = @"Yes";
static NSString *const MSG_NO  = @"No";
static NSString *const MSG_OK = @"OK";
static NSString *const MSG_CANCEL = @"Cancel";
static NSString *const MSG_MORE_INFO = @"More Info";
static NSString *const MSG_CONTINUE = @"Continue";
static NSString *const MSG_SKIP = @"Skip";
static NSString *const MSG_CONGRATS = @"Congratulations!";

static NSString *const MSG_ATTENTION = @"Attention!";

static NSString *const MSG_EXERCISE = @"exercise";
static NSString *const MSG_GLUCOSE = @"glucose";
static NSString *const MSG_MEAL = @"meal";
static NSString *const MSG_OTHER = @"other";

static NSString *const MSG_SCORE = @"Score";
static NSString *const MSG_WEIGHT = @"Weight";
static NSString *const MSG_BREAKFAST = @"Breakfast";
static NSString *const MSG_LUNCH = @"Lunch";
static NSString *const MSG_DINNER = @"Dinner";
static NSString *const MSG_SNACK = @"Snack";

static NSString *const MSG_NAVI_BAR_BACK = @"Back";

static NSString *const MSG_UPGRADING_DB = @"Upgrading Database...";
static NSString *const MSG_UPGRADING_DB_ERROR_ALERT_TITLE = @"Database Error";
static NSString *const MSG_UPGRADING_DB_ERROR_ALERT_CONTENT = @"Database could not be upgraded. Please restart the app to try again.";


#pragma mark - ChooseUnitViewController

static NSString *const UNIT_VC_TITLE_BG = @"Blood Glucose Unit";
static NSString *const UNIT_VC_TITLE_SYSTEM = @"Unit System";

#pragma mark - Add Glucose Record View Controller 
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEFORE_BREAKFAST = @"Before Breakfast";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_AFTER_BREAKFAST = @"After Breakfast";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEFORE_LUNCH = @"Before Lunch";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_AFTER_LUNCH = @"After Lunch";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEFORE_DINNER = @"Before Dinner";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_AFTER_DINNER = @"After Dinner";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEDTIME = @"Bedtime";
static NSString *const MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_OTHER = @"Other";


static NSString *const MSG_ADD_GLUCOSE_RECORD_RECORDING_TIME_TITLE = @"Recording time";

static NSString *const MSG_ADD_GLUCOSE_RECORD_SECTION_ENTER_BLOOD_GLUCOSE_TYPE_HEADER_TITLE = @"Enter blood glucose type:";
static NSString *const MSG_ADD_GLUCOSE_RECORD_SECTION_ENTER_BLOOD_GLUCOSE_LEVEL_HEADER_TITLE = @"Enter blood glucose level (%@):";

static NSString *const MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_HIGH_CONTENT = @"Your blood glucose level appears high. Monitor and adjust your meal plan and physical activity. Seek medical advice if it remains high.";

static NSString *const MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_LOW_CONTENT = @"Your blood glucose level appears low. Eat or drink 15g of carbs to increase your glucose levels. Seek medical advice if it remains low.";

static NSString *const MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_HIGH_TITLE = @"High Blood Glucose";

static NSString *const MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_LOW_TITLE = @"Low Blood Glucose";

#pragma mark - Add Meal Record Controller

static NSString *const MSG_ADD_MEAL_RECORD_UPDATE_RECENT_MEAL = @"Update Meal";
static NSString *const MSG_ADD_MEAL_RECORD_CREATE_NEW_MEAL = @"Log New Meal";
static NSString *const MSG_ADD_MEAL_RECORD_NO_SCORE_TITLE = @"Profile missing information";
static NSString *const MSG_ADD_MEAL_RECORD_NO_SCORE_BODY = @"Please make sure that your profile is setup properly. Your year of birth, gender, weight and height are required to calculate your meal score.";

static NSString *const MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_LONG = @"Modify Date & Time";
static NSString *const MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_SHORT = @"Modify Time";

static NSString *const MSG_ADD_MEAL_RECORD_BUTTON_SEE_NUTRITION_FACTS_LONG = @"See Nutrition Facts";
static NSString *const MSG_ADD_MEAL_RECORD_BUTTON_SEE_NUTRITION_FACTS_SHORT = @"Nutrition Facts";

static NSString *const MSG_ADD_MEAL_RECORD_CHOOSE_MEAL_TYPE_SLIDE_IN_TITLE = @"Choose Meal Type";
static NSString *const MSG_ADD_MEAL_RECORD_ADD_MEAL_NAME_ALERT_TITLE = @"Meal Name";
static NSString *const MSG_ADD_MEAL_RECORD_ADD_MEAL_NAME_ALERT_CONTENT = @"Give your meal a name";

static NSString *const MSG_ADD_MEAL_RECORD_DUPLICATE_FOOD_ALERT_TITLE = @"Duplicate Food Items";
static NSString *const MSG_ADD_MEAL_RECORD_DUPLICATE_FOOD_ALERT_CONTENT = @"Your meal contains duplicate food items.";

static NSString *const MSG_ADD_MEAL_RECORD_ADD_FOOD_ITEM = @"Add Food Item";

static NSString *const MSG_ADD_MEAL_RECORD_FOOD_RATING_LESS_OFTEN = @"Less Often";
static NSString *const MSG_ADD_MEAL_RECORD_FOOD_RATING_IN_MODERATION = @"In Moderation";
static NSString *const MSG_ADD_MEAL_RECORD_FOOD_RATING_MORE_OFTEN = @"More Often";

static NSString *const MSG_ADD_MEAL_RECORD_MEAL_TYPE_BREAKFAST = @"Breakfast";
static NSString *const MSG_ADD_MEAL_RECORD_MEAL_TYPE_LUNCH = @"Lunch";
static NSString *const MSG_ADD_MEAL_RECORD_MEAL_TYPE_DINNER = @"Dinner";
static NSString *const MSG_ADD_MEAL_RECORD_MEAL_TYPE_SNACK = @"Snack";

static NSString *const MSG_ADD_MEAL_RECORD_MEAL_TYPE_CHOOSER_CONTENT = @"Please Choose a Meal Type";

static NSString *const MSG_ADD_MEAL_RECORD_MEAL_SCORE_DESCRIPTION = @"Our algorithms will give your meal a score out of 100. The higher the score, the healthier your meal";

static NSString *const MSG_ADD_MEAL_RECORD_MEAL_SCORE_ADD_FOOD_FOR_SCORING = @"Add food for scoring";

static NSString *const MSG_ADD_MEAL_RECORD_CALS = @"%.1f cals";

#pragma mark - Barcode View Controller

static NSString *const MSG_BARCODE_FLASH_BUTTON = @"Flash";
static NSString *const MSG_BARCODE_ALERT_CAMERA_PROHIBITED = @"This app does not have permission to use the camera.";
static NSString *const MSG_BARCODE_ALERT_CAMERA_NOT_EXIST = @"This device does not have a camera.";
static NSString *const MSG_BARCODE_ALERT_CAMERA_UNKNOWN_ERROR = @"An unknown error occurred.";

#pragma mark - Goals View Controller

static NSUInteger const WEIGHT_GOAL_SECTION_LABEL_TAG = 1;
static NSUInteger const WEIGHT_GOAL_TARGET_PICKER_TAG = 2;

static NSString *const DAILY_STEP_COUNT_GOAL_TITLE = @"Daily Step Count Goal";
static NSString *const DAILY_STEP_COUNT_GOAL_CONTENT = @"Based on aggregated research, we have pre-set a daily step count goal of 7,500";

static NSString *const WEEKLY_STEP_COUNT_GOAL_TITLE = @"Weekly Step Count Goal";
static NSString *const WEEKLY_STEP_COUNT_GOAL_CONTENT = @"Based on aggregated research, we have pre-set a weekly step count goal of 37,500";

static NSString *const WEEKLY_MODVIG_GOAL_TITLE = @"Weekly Moderate And Vigorous Exercise Goal";
static NSString *const WEEKLY_MODVIG_GOAL_CONTENT = @"A total of 150 minutes or more of moderate or vigorous exercise is recommended for healthy adults.  Consult your physician prior to engaging in exercise at a level that you are not used to.  Should the pre-set goal be unsuitable for you, change it to a level that fits your lifestyle and modify it as you progress onwards.";

#pragma mark - Settings View Controller

static NSString *const SETTINGS_ROW_HOWTOVIDEO = @"How To...";
static NSString *const SETTINGS_ROW_PROFILE = @"Profile";
static NSString *const SETTINGS_ROW_INPUT_SELECTION = @"Input Selection";
static NSString *const SETTINGS_ROW_REMINDER = @"Set Reminder";
static NSString *const SETTINGS_ROW_LOGOUT = @"Logout";
static NSString *const SETTINGS_ROW_CONTACT = @"Contact Us";
static NSString *const SETTINGS_ROW_GOALS = @"Goals";
static NSString *const SETTINGS_ROW_HOME = @"Home";
static NSString *const SETTINGS_ROW_ONLINE_LOGBOOK = @"Online Logbook";

static NSString *const SETTINGS_ONLINE_LOGBOOK_MESSAGE = @"Access https://myaccount.glucoguide.com from a computer or tablet for a complete overview of your data, charts and trends.\n\nViewing through a smartphone is not recommended due to their small screen size.\n\nLog into your account with the email address and password you used when you created your personalized GoHealthNow account.";

static NSUInteger const SETTINGS_TAG_FOOTER_VERSION_LABEL = 1;
static NSUInteger const SETTINGS_TAG_FOOTER_COPYRIGHT_LABEL = 2;
static NSUInteger const SETTINGS_TAG_FOOTER_LOGO_IMAGE = 3;
static NSUInteger const SETTINGS_TAG_FOOTER_BRAND_NAME = 4;

#pragma mark - Notes View Controller

static NSUInteger const NOTES_CONTENT_LABEL_TAG = 1;
static NSUInteger const NOTES_DATE_LABEL_TAG = 2;
static NSUInteger const NOTES_TYPE_LABEL_TAG = 3;
static NSUInteger const NOTES_TABLE_EMPTY_MESSAGE_TAG = 4;

#pragma mark - Notes Detail Controller

static NSUInteger const NOTES_DETAIL_TAG_TYPE_VIEW = 1;
static NSUInteger const NOTES_DETAIL_TAG_TYPE_LABEL = 2;
static NSUInteger const NOTES_DETAIL_TAG_TEXT_VIEW = 3;

static NSString *const NOTES_DETAIL_CONTENT_PLACEHOLDER = @"Tap here to type your question.";

static NSString *const NOTES_DETAIL_SENDING_MSG = @"Sending note...";
static NSString *const NOTES_DETAIL_SUCESS_MSG = @"The note has been successfully sent!";
static NSString *const NOTES_DETAIL_FAILURE_MSG = @"The note could not be sent";

#pragma mark - Profile View Controller

static NSUInteger const PROFILE_EMAIL_IDX = 0;
static NSUInteger const PROFILE_NAME_IDX = 1;
static NSUInteger const PROFILE_SPECIAL_IDX = 2;
static NSUInteger const PROFILE_ORG_CODE_IDX = 3;
static NSUInteger const PROFILE_GENDER_IDX = 4;
static NSUInteger const PROFILE_BIRTH_YEAR_IDX = 5;
static NSUInteger const PROFILE_CONDITION_ETHNICITY_IDX = 6;
static NSUInteger const PROFILE_BGUNIT_IDX = 7;
static NSUInteger const PROFILE_UNIT_IDX = 8;
static NSUInteger const PROFILE_HEIGHT_IDX = 9;
static NSUInteger const PROFILE_WEIGHT_IDX = 10;
static NSUInteger const PROFILE_WAIST_SIZE_IDX = 11;
static NSUInteger const PROFILE_BMI_IDX = 12;
static NSUInteger const PROFILE_DAILY_CAL_DIST_IDX = 13;

static NSString *const PROFILE_VALUE_NOT_SET = @"Not Set";
static NSString *const PROFILE_VALUE_NONE_LOGGED = @"None Logged";

#pragma mark - RecommendationDetailViewController

static NSUInteger const RECOMMENDATION_DETAIL_TAG_IMAGE = 1;
static NSUInteger const RECOMMENDATION_DETAIL_TAG_TEXT_VIEW = 2;
static NSUInteger const RECOMMENDATION_DETAIL_TAG_DIVIDER = 3;
static NSUInteger const RECOMMENDATION_DETAIL_TAG_DETAILS_BUTTON = 4;

#pragma mark - HomeViewController

static NSUInteger const HOME_POINTS_CELL_TAG = 1;
static NSUInteger const HOME_POINTS_CELL_VAL_TAG = 2;
static NSUInteger const HOME_POINTS_CELL_GOAL_MSG_TAG = 3;

static NSUInteger const HOME_RECOMMENDATION_CELL_LABEL_TAG = 4;
static NSUInteger const HOME_RECOMMENDATION_CELL_IMAGE_TAG = 5;
static NSUInteger const HOME_RECOMMENDATION_EMPTY_MESSAGE_TAG = 6;

static NSUInteger const HOME_RECOMMENDATION_CARD_TAG = 2048;

#pragma mark - MedicationInputViewController

static NSString *const MEDICATION_ADDED = @"Medication Has Been Added To The List";
static NSString *const MEDICATION_IN_LIST = @"Medication Already In The List";

#pragma mark - InputViewController

static NSString *const INPUT_ROW_DIET = @"Diet";
static NSString *const INPUT_ROW_GLUCOSE = @"Blood Glucose";
static NSString *const INPUT_ROW_BLOODPRESSURE= @"Blood Pressure";
static NSString *const INPUT_ROW_EXERCISE = @"Exercise";
static NSString *const INPUT_ROW_SLEEP = @"Sleep";
static NSString *const INPUT_ROW_WEIGHT = @"Weight";
static NSString *const INPUT_ROW_BP = @"Blood Pressure";
static NSString *const INPUT_ROW_LABTEST = @"Lab Tests";
static NSString *const INPUT_ROW_MEDICATION = @"Medication";

static NSUInteger const INPUT_ROW_IMAGE_TAG = 1;
static NSUInteger const INPUT_ROW_LABEL_TAG = 2;
static NSUInteger const INPUT_ROW_PROGRESS_BAR_TAG = 3;
static NSUInteger const INPUT_ROW_PROGRESS_DESC_LABEL_TAG = 4;
static NSUInteger const INPUT_ROW_PROGRESS_VALUE_LABEL_TAG = 5;
static NSUInteger const INPUT_ROW_DETAIL_LABEL_TAG = 6;
static NSUInteger const INPUT_ROW_REMAINING_STEPS_LABEL_TAG = 300;

static NSUInteger const WEIGHT_INPUT_PICKER_TAG = 3333;
static NSUInteger const A1C_INPUT_VIEW_TAG = 4444;

static NSString *const INPUT_CONFIRM_SAVE_TITLE = @"Confirmation";
static NSString *const INPUT_CONFIRM_SAVE_MESSAGE = @"Changes to this %@ record will be lost. Do you want to continue?";
static NSString *const INPUT_CONFIRM_SAVE_YES_BTN = @"Yes";
static NSString *const INPUT_CONFIRM_SAVE_NO_BTN = @"No";

#pragma mark - InputSelectionViewController

static NSString *const INPUT_SELECTION_ROW_DIET = @"Diet";
static NSString *const INPUT_SELECTION_ROW_GLUCOSE = @"Blood Glucose";
static NSString *const INPUT_SELECTION_ROW_BLOODPRESSURE = @"Blood Pressure";
static NSString *const INPUT_SELECTION_ROW_EXERCISE = @"Exercise";
static NSString *const INPUT_SELECTION_ROW_SLEEP = @"Sleep";
static NSString *const INPUT_SELECTION_ROW_WEIGHT = @"Weight";
static NSString *const INPUT_SELECTION_ROW_BP = @"Blood Pressure";
static NSString *const INPUT_SELECTION_ROW_A1C = @"A1C";
static NSString *const INPUT_SELECTION_ROW_LABTEST = @"Lab Tests";
static NSString *const INPUT_SELECTION_ROW_MEDICATION = @"Medication";

static NSUInteger const INPUT_SELECTION_ROW_IMAGE_TAG = 1;
static NSUInteger const INPUT_SELECTION_ROW_LABEL_TAG = 2;
static NSUInteger const INPUT_SELECTION_HEADER_LABEL_TAG = 1;


static NSString *const INPUT_SELECTION_SUCESS_MSG = @"Your selected inputs have been saved successfully!";


#pragma mark - FoodSummaryController

static NSUInteger const FSUMM_SERVING_SIZE_VIEW_TAG = 5555;
static NSUInteger const FSUMM_SERVING_SIZE_UNIT_VIEW_TAG = 5556;
static NSUInteger const FSUMM_SERVING_SIZE_UNIT_PICKER_TAG = 5557;
static NSUInteger const FSUMM_SECTION_HEADER_TAG = 5558;
static NSUInteger const FSUMM_SECTION_HEADER_IMG_TAG = 5559;
static NSUInteger const FSUMM_SECTION_HEADER_TOP_PREDICTIONS_BTN_TAG = 5560;
static NSUInteger const FSUMM_TOP_PREDICTIONS_PICKER_TAG = 5561;
static NSInteger const  FSUMM_INDEX_NOT_SET = -1234;

static CGFloat const FSUMM_0_SECTION_HEADER_HEIGHT = 80.0;
static CGFloat const FSUMM_SECTION_HEADER_HEIGHT = 60.0;
static CGFloat const FSUMM_SECTION_HEADER_IMG_TOP_MARGIN = 4.0;

static NSString *const FSUMM_FROM_FOOD_RECOGNITION_TITLE = @"From Food Recognition";
static NSString *const FSUMM_PREDICTIONS_TITLE = @"Top %ld Predictions";

static NSString *const MSG_FSUMM_ABOUT_FOOD_RECOGNITION_TITLE = @"About Food Recognition";
static NSString *const MSG_FSUMM_ABOUT_FOOD_RECOGNITION_CONTENT = @"This food item was recognized by our smart food recognition algorithm, and we provided those estimated nutritional values based on recognition results.";

static NSString *const FSUMM_SERVING_SIZE_TITLE = @"Serving Size";
static NSString *const FSUMM_YOUR_SELECTION_TITLE = @"Your Selection";

#pragma mark - All Add Record View Controllers

static CGFloat const ADD_RECORD_BUTTON_ROW_HEIGHT = 95.0;
static CGFloat const ADD_RECORD_PICKER_ROW_HEIGHT = 230.0;
static CGFloat const ADD_RECORD_TABLE_SECTION_HEADER_HEIGHT = 45.0;

static NSString *const ADD_RECORD_SUCESS_MSG = @"Record has been saved sucessfully!";
static NSString *const ADD_RECORD_FAILURE_MSG = @"Record failed to save";
static NSString *const ADD_RECORD_SAVING_MSG = @"Saving record...";

#pragma mark - User Setup Page View Controller

static NSString *const USER_SAVING_MSG = @"Saving user...";

#pragma mark - User Setup First View Controller

static NSUInteger const USER_SETUP_FIRST_VC_TAG_NAV_BAR = 1;
static NSUInteger const USER_SETUP_FIRST_VC_TAG_MAIN_LABEL = 2;
static NSUInteger const USER_SETUP_FIRST_VC_TAG_SKIP_BUTTON = 3;
static NSUInteger const USER_SETUP_FIRST_VC_TAG_CONT_BUTTON = 4;

#pragma mark - BloodGlucoseSummaryViewController

static NSUInteger const BLOOD_GLUCOSE_SUMMARY_TAG_CELL_CARD_VIEW = 1;
static NSUInteger const BLOOD_GLUCOSE_SUMMARY_TAG_BG_ICON = 2;
static NSUInteger const BLOOD_GLUCOSE_SUMMARY_TAG_LOG_TYPE_LABEL = 3;
static NSUInteger const BLOOD_GLUCOSE_SUMMARY_TAG_LOG_TIME_LABEL = 4;
static NSUInteger const BLOOD_GLUCOSE_SUMMARY_TAG_BG_VALUE_LABEL = 5;
static NSUInteger const BLOOD_GLUCOSE_SUMMARY_TAG_NOTE_LABEL  = 6;

static NSString *const MSG_BLOOD_GLUCOSE_SUMMARY_SECTION_HEADER_CATEGORY = @"category";

#pragma mark - BloodPressureSummaryViewController
static NSString *const MSG_BLOOD_PRESSURE_SUMMARY_SECTION_HEADER_CATEGORY = @"category";
static NSUInteger const BP_SYSTOLIC_LABEL_TAG = 1;
static NSUInteger const BP_DIASTOLIC_LABEL_TAG = 2;
static NSUInteger const BP_PULSE_LABEL_TAG = 3;
static NSUInteger const BP_NOTE_LABEL_TAG = 4;
static NSUInteger const BP_RECORDEDTIME_LABEL_TAG = 5;

#pragma mark - A1CRecordViewController

static NSUInteger const A1CLEVEL_TAG_NUMBER_PICKER = 1;
static NSUInteger const A1CLEVEL_TAG_DECIMAL_PICKER = 2;
static NSUInteger const A1CLEVEL_TAG_DECIMAL_DOT = 3;
static NSUInteger const A1CLEVEL_TAG_PER_LABEL = 4;
static NSUInteger const A1CLEVEL_TAG_SECTION_HEADER_LABEL = 5;
static NSUInteger const A1CLEVEL_TAG_RECORDINGTIME_LABEL = 6;

static CGFloat const ADD_A1C_PICKER_ROW_HEIGHT = 180.0;

#pragma mark - LabTestTableViewController
static NSUInteger const LAB_TEST_TAG_RECORD_CELL_TITLE_LABEL = 11;
static NSUInteger const LAB_TEST_TAG_RECORD_CELL_DATE_LABEL = 12;
static NSUInteger const LAB_TEST_TAG_RECORD_CELL_VALUE_LABEL = 13;

#pragma mark - WeightRecordViewController

static NSUInteger const WEIGHT_TAG_PICKER = 2;
static NSUInteger const WEIGHT_TAG_RECORDINGTIME_LABEL = 4;
static NSUInteger const WEIGHT_TAG_SECTION_HEADER_TEXTVIEW = 5;

static CGFloat const ADD_WEIGHT_PICKER_ROW_HEIGHT = 180.0;



#pragma mark - AddGlucoseRecordViewController

static NSUInteger const ADD_GLUCOSE_TAG_TYPE_CELL_PICKER = 1;
static NSUInteger const ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MMOLL_PICKER = 2;
static NSUInteger const ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_PICKER = 3;
static NSUInteger const ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_DOT = 6;
static NSUInteger const ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER = 9;
static NSUInteger const ADD_GLUCOSE_TAG_TIME_CELL_LABEL = 3;
static NSUInteger const ADD_GLUCOSE_TAG_TIME_CELL_VALUE_LABEL = 4;
static NSUInteger const ADD_GLUCOSE_TAG_TIME_CELL_TOP_BORDER = 7;
static NSUInteger const ADD_GLUCOSE_TAG_TIME_CELL_BOTTOM_BORDER = 8;
static NSUInteger const ADD_GLUCOSE_TAG_SECTION_HEADER_LABEL = 5;

static CGFloat const ADD_GLUCOSE_PICKER_ROW_HEIGHT = 160.0;

static CGFloat const ADD_GLUCOSE_WARNING_MIN_MMOL_VAL = 4.0;
static CGFloat const ADD_GLUCOSE_WARNING_MAX_MMOL_VAL = 11.0;

static NSString *const ADD_GLUCOSE_KEY_PROMPT_ALERT = @"promptAlert";
static NSString *const ADD_GLUCOSE_KEY_WARNING_ALERT = @"warningAlert";

#pragma mark - MedicationSummaryTableViewController

static NSUInteger const MEDICATION_SUMMARY_TAG_CELL_CARD_VIEW = 1;
static NSUInteger const MEDICATION_SUMMARY_TAG_MED_ICON = 2;
static NSUInteger const MEDICATION_SUMMARY_TAG_MED_NAME_LABEL = 3;
static NSUInteger const MEDICATION_SUMMARY_TAG_LOG_TIME_LABEL = 4;
static NSUInteger const MEDICATION_SUMMARY_TAG_DOSEAGE_VALUE_LABEL = 5;
static NSUInteger const MEDICATION_SUMMARY_TAG_NOTE_LABEL = 6;


#pragma mark - AddSleepRecordViewController

static NSUInteger const ADD_SLEEP_TAG_HOUR_CELL_PICKER = 1;
static NSUInteger const ADD_SLEEP_TAG_MIN_CELL_PICKER = 2;
static NSUInteger const ADD_SLEEP_TAG_HOUR_LABEL = 3;
static NSUInteger const ADD_SLEEP_TAG_MIN_LABEL = 4;
static NSUInteger const ADD_SLEEP_TAG_QUESTION_LABEL = 5;
static NSUInteger const ADD_SLEEP_TAG_QUESTION_SWITCH = 6;
static NSUInteger const ADD_SLEEP_TAG_SECTION_HEADER_LABEL = 7;

static CGFloat const ADD_SLEEP_QUESTION_ROW_HEIGHT = 50.0;

static NSString *const MSG_ADD_SLEEP_RECORD_QUESTION_ARE_YOU_SICK = @"Are you sick?";
static NSString *const MSG_ADD_SLEEP_RECORD_QUESTION_ARE_YOU_STRESSED_OUT = @"Are you stressed out?";
static NSString *const MSG_ADD_SLEEP_RECORD_QUESTION_HOW_LONG_DID_YOU_SLEEP_LAST_NIGHT = @"How long did you sleep last night?";
static NSString *const MSG_ADD_SLEEP_RECORD_QUESTION_ABOUT_TODAY = @"About today:";

#pragma mark - AddExerciseRecordViewController

static NSUInteger const ADD_EXERCISE_TAG_SECTION_HEADER_LABEL = 1;
static NSUInteger const ADD_EXERCISE_TAG_TIME_CELL_LABEL = 2;
static NSUInteger const ADD_EXERCISE_TAG_TIME_CELL_VALUE_LABEL = 3;
static NSUInteger const ADD_EXERCISE_TAG_TIME_CELL_TOP_BORDER = 4;
static NSUInteger const ADD_EXERCISE_TAG_TIME_CELL_BOTTOM_BORDER = 5;
static NSUInteger const ADD_EXERCISE_TAG_HOUR_CELL_PICKER = 6;
static NSUInteger const ADD_EXERCISE_TAG_MIN_CELL_PICKER = 7;
static NSUInteger const ADD_EXERCISE_TAG_HOUR_LABEL = 8;
static NSUInteger const ADD_EXERCISE_TAG_MIN_LABEL = 9;

static CGFloat const ADD_EXERCISE_BUTTON_ROW_HEIGHT = 230.0;

static NSUInteger const ADD_EXERCISE_ABNORMAL_MODERATE_MINS = 25;
static NSUInteger const ADD_EXERCISE_ABNORMAL_VIGOROUS_MINS = 10;
static NSString *const ADD_EXERCISE_ABNORMAL_ALERT_TITLE = @"Abnormal %@ Exercise Minutes";
static NSString *const ADD_EXERCISE_ABNORMAL_ALERT_BODY = @"%@ exercise is beneficial but you should increase the duration slowly. Are you sure the duration of your %@ exercise is %ld minutes?";
static NSString *const MSG_ADD_EXERCISE_TIME_CELL_TITLE = @"Start Time";
static NSString *const MSG_ADD_EXERCISE_HEADER_TYPE_UNKNOWN = @"Unknown";
static NSString *const MSG_ADD_EXERCISE_HEADER_TYPE_EXERCISE_DURATION = @"%@ exercise duration";

#pragma mark - ExerciseHistoryTableviewController

static NSUInteger const EXERCISE_HISTORY_CELL_BASE_VIEW = 1;
static NSUInteger const EXERCISE_HISTORY_CELL_ADDED_TYPE_LABEL = 2;
static NSUInteger const EXERCISE_HISTORY_CELL_EXERCISE_TYPE_IMAGE = 3;
static NSUInteger const EXERCISE_HISTORY_CELL_EXERCISE_TYPE_DESP = 4;
static NSUInteger const EXERCISE_HISTORY_CELL_RECORDED_TIME = 5;
static NSUInteger const EXERCISE_HISTORY_CELL_EXERCISE_DURATION = 6;

static NSString *const EXERCISE_HISTORY_MANUAL_ADD = @"Manually added";
static NSString *const EXERCISE_HISTORY_AUTO_ADD = @"Automatically Added";

#pragma mark - SearchFoodController

static NSUInteger const SEARCH_FOOD_TAG_MEAL_IMAGE = 1;
static NSUInteger const SEARCH_FOOD_TAG_MEAL_LABEL = 2;
static NSUInteger const SEARCH_FOOD_TAG_MEAL_DESC_LABEL = 3;
static NSUInteger const SEARCH_FOOD_TAG_SECTION_HEADER_LABEL = 4;
static NSUInteger const SEARCH_FOOD_TAG_CAMERA_BUTTON = 5;

static NSUInteger const SEARCH_FOOD_RECENT_LIST_MAX_COUNT = 10;

#pragma mark - QuickEstimateController

static NSUInteger const QUICK_ESTIMATE_TAG_TEXT_INPUT_PORTIONSIZE = 1;
static NSUInteger const QUICK_ESTIMATE_TAG_TEXT_INPUT_CARBS = 2;
static NSUInteger const QUICK_ESTIMATE_TAG_TEXT_INPUT_FATS = 3;
static NSUInteger const QUICK_ESTIMATE_TAG_TEXT_INPUT_PROTEIN = 4;
static NSUInteger const QUICK_ESTIMATE_TAG_CLASSIFICATION_LBL_PICKER = 5;

static NSString  *const QUICK_ESTIMATE_MSG_TEXT_INPUT_PROTIONSIZE = @"Calories";
static NSString  *const QUICK_ESTIMATE_MSG_TEXT_INPUT_CARBS = @"Carbs";
static NSString  *const QUICK_ESTIMATE_MSG_TEXT_INPUT_FATS = @"Fat";
static NSString  *const QUICK_ESTIMATE_MSG_TEXT_INPUT_PROTEIN = @"Protein";

static NSString *const QUICK_ESTIMATE_UNKNOWN_MEAL_NAME = @"Unknown";

#pragma mark - QuickEstimateDetailModeController

static NSString  *const QUICK_ESTIMATE_DETAIL_MODE_MSG_MORE_FIBRE = @"Include more fibre";
static NSString  *const QUICK_ESTIMATE_DETAIL_MODE_MSG_REDUCE_FAT = @"Reduce unhealthy fat";
static NSString  *const QUICK_ESTIMATE_DETAIL_MODE_MSG_REDUCE_SALT= @"Reduce salt";

#pragma mark - HelpTipController

static CGFloat const HELP_TIP_CTRL_POINT_RADIUS = 150.0;
static CGFloat const HELP_TIP_CTRL_POINT_LEFT_ANGLE = 135.0;
static CGFloat const HELP_TIP_CTRL_POINT_RIGHT_ANGLE = 45.0;
static CGFloat const HELP_TIP_ARROW_TAIL_MARGIN_MULTIPLIER = 5.0;
static CGFloat const HELP_TIP_DEFAULT_TITLE_WIDTH = 296.0;

static NSString *const HELP_TIP_BUTTON_TITLE = @"Press the info button here to view this screen again at any time";

#pragma mark - ProgressViewController

static NSString *const PROG_KEY_TIME_INTV_FOR_GRAPH = @"timeIntervalForGraph";
static NSString *const PROG_KEY_INTV_CTL = @"intervalCtl";

static NSString *const PROG_KEY_DATA = @"data";
static NSString *const PROG_KEY_TYPE = @"type";
static NSString *const PROG_KEY_TITLE = @"title";
static NSString *const PROG_KEY_X_RANGE_DATE_MIN = @"xRangeDateMin";
static NSString *const PROG_KEY_X_RANGE_DATE_MAX = @"xRangeDateMax";
static NSString *const PROG_KEY_DATE_INTERVAL = @"dateInterval";
static NSString *const PROG_KEY_X_DATE_INTERVAL = @"xAxisDateInterval";
static NSString *const PROG_KEY_Y_RANGE_MIN = @"yRangeMin";
static NSString *const PROG_KEY_Y_RANGE_MAX = @"yRangeMax";
static NSString *const PROG_KEY_Y_INTERVAL = @"yAxisInterval";
static NSString *const PROG_KEY_X_RANGE_MIN = @"xRangeMin";
static NSString *const PROG_KEY_X_RANGE_MAX = @"xRangeMax";
static NSString *const PROG_KEY_X_INTERVAL = @"xAxisInterval";

// Average Meal Score Chart
static NSUInteger const PROG_AVG_MEAL_SCORE_TYPE = 1;
static NSString *const PROG_AVG_MEAL_SCORE_TITLE = @"Average meal score";
static CGFloat const PROG_AVG_MEAL_SCORE_Y_RANGE_MIN = 0;
static CGFloat const PROG_AVG_MEAL_SCORE_Y_RANGE_MAX = 100;
static CGFloat const PROG_AVG_MEAL_SCORE_Y_INTERVAL = 20;

// Exercise Minutes Chart
static NSUInteger const PROG_EXERCISE_MINS_TYPE = 0;
static NSString *const PROG_EXERCISE_MINS_TITLE = @"Exercise minutes";
static CGFloat const PROG_EXERCISE_MINS_Y_RANGE_MIN = 0;
static CGFloat const PROG_EXERCISE_MINS_Y_RANGE_MAX = 200;
static CGFloat const PROG_EXERCISE_MINS_Y_INTERVAL = 100;

// Daily Calorie Balance Chart
static NSUInteger const PROG_DAILY_CALS_TYPE = 0;
static NSString *const PROG_DAILY_CALS_TITLE = @"Daily calories balance";
static CGFloat const PROG_DAILY_CALS_Y_RANGE_MIN = 0;

// Blood glucose (Fasting) Chart
static NSUInteger const PROG_BG_FAST_TYPE = 1;
static NSString *const PROG_BG_FAST_TITLE = @"Blood glucose (Fasting)";
static CGFloat const PROG_BG_FAST_Y_RANGE_MIN = 0;

// Weight Chart
static NSUInteger const PROG_WEIGHT_TYPE = 1;
static NSString *const PROG_WEIGHT_TITLE = @"Weight";
static CGFloat const PROG_WEIGHT_Y_RANGE_MIN = 0;

static NSString *const PROG_NO_DATA_WEIGHT_TITLE = @"Log your weight to view your progress";
static NSString *const PROG_NO_DATA_MEAL_SCORE_TITLE = @"Log your meals to view your progress";
static NSString *const PROG_NO_DATA_DAILY_CALS_TITLE = @"Log your meals to view your progress";
static NSString *const PROG_NO_DATA_BG_FAST_TITLE = @"Log your blood glucose to view your progress";
static NSString *const PROG_NO_DATA_EXERCISE_TITLE = @"Log your exercise to view your progress";

static NSUInteger const PROG_NO_DATA_WEIGHT_TAG = 300;
static NSUInteger const PROG_NO_DATA_MEAL_SCORE_TAG = 301;
static NSUInteger const PROG_NO_DATA_DAILY_CALS_TAG = 302;
static NSUInteger const PROG_NO_DATA_BG_FAST_TAG = 303;
static NSUInteger const PROG_NO_DATA_EXERCISE_TAG = 304;

#pragma mark - RecentMealsController

static NSUInteger const RECENT_MEALS_TAG_IMAGE_CARD = 1;

static NSUInteger const RECENT_MEALS_TAG_LABEL = 2;
static NSUInteger const RECENT_MEALS_TAG_SUB_LABEL = 3;
static NSUInteger const RECENT_MEALS_TAG_IMAGE = 4;

#pragma mark - RecentExerciseTableViewController

static NSUInteger const RECENT_EXERCISE_CELL_LABEL_ADDED_TYPE = 2;
static NSUInteger const RECENT_EXERCISE_CELL_IMAGE_EXERCISE = 3;
static NSUInteger const RECENT_EXERCISE_CELL_LABEL_EXERCISE_TYPE = 4;
static NSUInteger const RECENT_EXERCISE_CELL_LABEL_ADDED_TIME = 5;
static NSUInteger const RECENT_EXERCISE_CELL_LABEL_DURATION = 6;

#pragma mark - Exercise Summary
static NSString *const EXERCISE_STEP_COUNT_CONTENT = @"GoHealthNow’s pedometer feature tracks your steps automatically on your phone, so you need to have another wearable device!  Just put your phone in your pants pockets or attach it to an armband when you walk, brisk walk, or run. Based on your speed, the app can determine whether your exercise is Light, Moderate, or Vigorous. It is simple and effective! Based on aggregated research, we have pre-set a daily step count goal of 7,500. You can always change it in “Set Your Goals.“";
static NSString *const EXERCISE_STEP_COUNT_CONTENT_TITLE = @"Step Count Information";

#pragma mark - Exercise History Day ViewController
static NSString *const EXERCISE_CALORIE_CONTENT_TITLE = @"Calorie Information";
static NSString *const EXERCISE_CALORIE_TITLE = @"Your body is constantly burning calories even when you are at rest. Thus, the recorded calories burnt in exercise is a rough estimate.  Do not be discouraged by the small amount of calories burnt.  Being active is key. As you becomes more active, you can gradually increase your exercise duration and intensity.";

static NSString *const EXERCISE_DAILY_NO_INFO_TITLE = @"No Infomation";
static NSString *const EXERCISE_DAILY_NO_INFO_CONTENT = @"No Light, Moderate, or Vigorous Mintues Were Recorded";


#pragma mark - ChooseExerciseTypeViewController

static NSUInteger const EXERCISE_TYPE_TAG_TYPE_LABEL = 1;
static NSUInteger const EXERCISE_TYPE_TAG_DESC_LABEL = 2;
static NSUInteger const EXERCISE_TYPE_TAG_EXAMPLE_LABEL = 3;

static NSString *const EXERCISE_TYPE_LIGHT = @"Light";
static NSString *const EXERCISE_TYPE_MODERATE = @"Moderate";
static NSString *const EXERCISE_TYPE_VIGOROUS = @"Vigorous";

static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_DESC = @"Feels like you can maintain activity for hours. It is easy to breath and carry a conversation.";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_LIGHT_WALKING = @"light walking";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_YOGA = @"yoga";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_TAICHI = @"tai chi";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_LIGHT_HOUSEWORK = @"light housework like dusting";

static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_DESC = @"Feels like you are working comfortably while breathing heavily and can hold a short conversation.";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_WALKING_BRISKLY = @"walking briskly";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_WATER_AEROBICS = @"water aerobics";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_BICYCLING_SLOWLY = @"bicycling slowly";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_TENNIS = @"tennis (doubles)";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_BALLROOM_GARDENING = @"ballroom dancing";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_GENERAL_GARDENING = @"general gardening";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_HEAVY_HOUSEWORK = @"heavy housework like vacuuming, mopping, scrubbing etc.";

static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_INFO_DESC = @"On the verge of becoming uncomfortable, short of breath and can speak a sentence or two.";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_RACE_WALKING = @"race walking";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_JOGGING = @"jogging";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_RUNNING = @"running";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_SWIMMING_LAPS = @"swimming laps";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_TENNIS = @"tennis (singles)";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_AEROBICS = @"aerobics";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_BICYCLING = @"bicyling fast";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_JUMPING_ROLE = @"jumping rope";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_HEAVY_GARDENING = @"heavy gardening (digging or hoeing)";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_HIKING_UPHILL = @"Hiking uphill";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_INTENSE_WEIGHT_LIFTING = @"intense weight lifting";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_INTERVAL_TRAINING = @"interval training";
static NSString *const MSG_CHOOSE_EXERCISE_TYPE_VIEW_EXERCISE_EXAMPLE = @"Examples:\n\n%@";

static NSString *const MSG_CHOOSE_EXERCISE_HEADER_CONTENT_WITH_PEDOMETER = @"If you do other types of exercise such as swimming, or if you didn't carry your phone when you walk, you can enter your exercise here.\n\nIf you allowed Motion Tracking, minutes from vigorous or moderate walking and running will be automatically entered";
static NSString *const MSG_CHOOSE_EXERCISE_HEADER_CONTENT_WITHOUT_PEDOMETER = @"If you do other types of exercise such as swimming, you can enter your exercise here.";


enum {
    ExerciseTypeLight = 0,
    ExerciseTypeModerate,
    ExerciseTypeVigorous
};
typedef NSUInteger ExerciseType;

static NSString *const EXERCISE_INFO_TYPE = @"type";
static NSString *const EXERCISE_INFO_COLOR = @"color";
static NSString *const EXERCISE_INFO_DESC = @"description";
static NSString *const EXERCISE_INFO_EXAMPLES = @"examples";
static NSString *const EXERCISE_INFO_CALS_PER_UNIT = @"calsPerUnit";

#pragma mark - MealPhotoViewController

static NSString *const MEAL_PHOTO_TEXT_VIEW_PLACEHOLDER = @"You can take photo(s) of your food. GoHealthNow, together with nutrition experts, will analyze your photo and provide you with nutrition advice (only for users with a valid access code). You will be notified shortly.\n\nIf you have any questions about this meal, enter here.";

#pragma mark - ExerciseSummaryViewController

static NSString *const EXERCISE_SUMMARY_GOAL_TITLE = @"Weekly Moderate and Vigorous Minutes";
static NSString *const EXERCISE_SUMMARY_GOAL_CONTENT = @"If you have diabetes, your goal is to accumulate a minimum of 150 mins of moderate and vigorous exercise per week, as recommended by the CDA and the ADA.\n\nThe ACSM recommends a minimum of 150 mins per week to achieve weight loss and a minimum of 250 mins per week to prevent weight regain.";

static NSString *const EXERCISE_SUMMARY_STEP_GOAL_TITLE = @"Step Count Goals";
static NSString *const EXERCISE_SUMMARY_STEP_GOAL_CONTENT = @"Based on your age and extensive research, we think this would be a good daily step goal.\n\n You can always change it in “Set Your Own Goals”. However, step counts do not consider how fast you walk, jog, or run. Thus we automatically convert your step counts to Light, Moderate, or Vigorous exercise minutes.\n\n If you live with diabetes, CDA and ADA recommends that you accumulate a minimum 150 min of Moderate and Vigorous exercise per week.";

static NSUInteger const EXERCISE_SUMMARY_MAX_WEEKLY_LIGHT_TARGET_MINS = 300;
static NSUInteger const EXERCISE_SUMMARY_MAX_WEEKLY_MOD_VIG_TARGET_MINS = 150;

static NSString *const EXERCISE_WEEKLY_MINS_INFO_KEY_LIGHT = @"weeklyLightMinsTotal";
static NSString *const EXERCISE_WEEKLY_MINS_INFO_KEY_MODVIG = @"weeklyModVigMinsTotal";
static NSString *const EXERCISE_WEEKLY_MINS_INFO_KEY_LIGHT_TARGET = @"weeklyLightTarget";
static NSString *const EXERCISE_WEEKLY_MINS_INFO_KEY_MODVIG_TARGET = @"weeklyModVigTarget";

static NSString *const EXERCISE_GOAL_DAILY_STEP_COUNT_HAS_BEEN_FINISHED = @"You have reached your daily step count goal.\n\n Your new daily step count goal has been increased by 1000 steps.";
static NSString *const EXERCISE_GOAL_WEEKLY_STEP_COUNT_HAS_BEEN_FINISHED = @"You have reached your weekly step count goal.\n\n Your new weekly step count goal has been increased by 5000 steps.";

#pragma mark - IntroContentViewController

static NSString *const INTRO_CONTENT_MODE_WELCOME = @"welcome";
static NSString *const INTRO_CONTENT_MODE_INSTRUCTIONS = @"instructions";
static NSString *const INTRO_CONTENT_MODE_SHOWAUTOLAUNCH = @"showautolaunch";

#pragma mark - RegisterLoginViewController

static NSString *const REGISTER_REGESTERING_MSG = @"Registering...";
static NSString *const REGISTER_LOGIN_MSG = @"Logging in...";
static NSString *const EULA_URL = @"http://gohealthnow.ca/EULA";
static NSString *const ALERT_EULA_MESSAGE = @"By registering, you agree to our EULA. After registration, you will receive a verification email.  Please verify your account to continue using GoHealthNow.";
static NSString *const ERROR_EMAIL = @"INVALID EMAIL";
static NSString *const ERROR_PASSWORD = @"PASSWORD IS TOO SHORT";
static NSString *const EULA_ALERT_AGREE = @"Continue";
static NSString *const EULA_ALERT_VIEW_EULA = @"View EULA";

#pragma mark - ChooseBirthYearViewController

static NSUInteger const FIRST_AVAILABLE_BIRTH_YEAR = 1900;

#pragma mark - ChooseHeightViewController

static NSString *const CHOOSE_HEIGHT_WARNING_MSG = @"Your height seems too short. Please input your height correctly(Not less than 40cm/1ft 4inch).";
static NSUInteger const CHOOSE_HEIGHT_LOWER_HEIGHT_BOUND = 40.0f;

#pragma mark - ChooseWeightViewController

static NSString *const CHOOSE_WEIGHT_WARNING_MSG = @"Your weight seems too low. Please input your weight correctly(Not less than 10kg/23lb).";
static NSUInteger const CHOOSE_WEIGHT_LOWER_WEIGHT_BOUND = 10.0;

#pragma mark - ChooseInsulinController

static NSUInteger const CHOOSE_INSULIN_TAG_NAME_LABEL = 1;
static NSUInteger const CHOOSE_INSULIN_TAG_SWITCH = 2;

#pragma mark - CalorieDistributionController

static NSUInteger const CHOOSE_CAL_DIST_TAG_CELL_LABEL = 1;
static NSUInteger const CHOOSE_CAL_DIST_TAG_CELL_TEXT_FIELD = 2;

static NSUInteger const CHOOSE_CAL_DIST_TAG_ALERT_TEXT_FIELD = 3;
static NSUInteger const CHOOSE_CAL_DIST_TAG_TARGET_CALS_LABEL = 4;
static NSUInteger const CHOOSE_CAL_DIST_TAG_TYPICAL_DAY_LABEL = 5;

static CGFloat const MIN_CAL_PERCENTAGE_FOR_CARBS = 0.45;
static CGFloat const MAX_CAL_PERCENTAGE_FOR_CARBS = 0.60;

static NSString *const MSG_CALORIE_DISTRIBUTION_BUTTON_CONTINUE = @"Continue";

static NSString *const MSG_CALORIE_DISTRIBUTION_ALERT_PLEASE_INPUT_PERCT = @"Please input your %@ percentage";

static NSString *const MSG_CALORIE_DISTRIBUTION_MAX_VALUE = @"Maximum value: 100";
static NSString *const MSG_CALORIE_DISTRIBUTION_INVALID_NUMBER_ALERT_TITLE = @"Invalid number";
static NSString *const MSG_CALORIE_DISTRIBUTION_INVALID_NUMBER_ALERT_CONTENT = @"Please input a number less than or equal to 100";

static NSString *const MSG_CALORIE_DISTRIBUTION_INVALID_PERCENTAGE_ALERT_CONTENT = @"Your total percentage value must add up to 100";

static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_MEAL_OR_SNACK = @"Meal/Snack";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_CALORIES = @"Calories";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_CARBS = @"Carbs (g)";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_BREAKFAST = @"Breakfast";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_LUNCH = @"Lunch";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_DINNER = @"Dinner";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_3SNACKS = @"3 Snacks";
static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_TOTAL = @"Total";

static NSString *const MSG_CALORIE_DISTRIBUTION_HEADER_CLAORIES = @"%@ calories";


#pragma mark - DosageInputViewController
static NSString *const INPUT_NOTIFICATION_LOG                         = @"Log Time";
static NSString *const INPUT_NOTIFICATION_DAILY                       = @"Daily";

static NSString *const INPUT_NOTIFICATION_CREATION_ALERT_TITLE        = @"Reminder Notification Created";
static NSString *const INPUT_NOTIFICATION_UPDATE_ALERT_TITLE          = @"Reminder Notification Updated";

static NSString *const INPUT_NOTIFICATION_SELECTED_MEASUREMENT_MG     = @"mg";
static NSString *const INPUT_NOTIFICATION_SELECTED_MEASUREMENT_ML     = @"mL";

static NSString *const INPUT_NOTIFICATION_MEDICATION_TITLE            = @"Medication Record";
static NSString *const INPUT_NOTIFICATION_MODIFY_TITLE                = @"Modify Reminder";

#pragma mark - StyleManager

static const NSUInteger STYLE_TITLE_PADDING = 5;
static const NSUInteger STYLE_VIEW_BACKGROUND_MASK_TAG = 56345;

#pragma mark - GGProgressView

static NSUInteger const PROGRESS_VIEW_TAG = 1;

#pragma mark - Common

static NSString *const ALERT_TITLE_OOPS = @"Small Issue. Please Try Again.";

static NSString *const STORYBOARD_ID_USER_SETUP_FIRST = @"userSetupFirstViewController";
static NSString *const STORYBOARD_ID_ORG_CODE = @"chooseOrganizationCodeViewController";
static NSString *const STORYBOARD_ID_USER_NAME = @"chooseNameViewController";
static NSString *const STORYBOARD_ID_GENDER = @"chooseGenderViewController";
static NSString *const STORYBOARD_ID_BIRTH_YEAR = @"chooseBirthYearViewController";
static NSString *const STORYBOARD_ID_MEASURE_UNIT = @"chooseUnitViewController";
static NSString *const STORYBOARD_ID_WEIGHT = @"chooseWeightViewController";
static NSString *const STORYBOARD_ID_HEIGHT = @"chooseHeightViewController";
static NSString *const STORYBOARD_ID_BMI_WAIST = @"chooseBMIAndWaistViewController";
static NSString *const STORYBOARD_ID_REMINDERS = @"reminderInputViewController2";
static NSString *const STORYBOARD_ID_CAL_DIST = @"calorieDistributionController";

// <!-- 0: lose weight; 1: gain weight -->
typedef enum {
    WeightGoalTypeLoseWeight = 0,
    WeightGoalTypeGainWeight
} WeightGoalType;

// 0: Light; 1: Moderate/Vigorous; 2: daily step count ; 3: weekly step count-->

typedef enum {
    GoalTypeExerciseLight = 0,
    GoalTypeExerciseModerateVigorous,
    GoalTypeExerciseDailyStepsCount,
    GoalTypeExerciseWeeklyStepsCount,
    GoalTypeWeight
} GoalType ;   // NOTE: PLEASE DON'T CHANGE THE ORDER OF THOSE GOAL TYPES, AND ALWAYS PUT WEIGHT AT THE LAST

static NSUInteger const GOALS_TYPE_COUNT = 5; // please update if new goal type added.

static NSUInteger const GOAL_EXERCISE_DAILY_STEP_MAX_VALUE = 5000000;
static NSUInteger const GOAL_EXERCISE_WEEKLY_STEP_MAX_VALUE = 3500000;
static NSUInteger const GOAL_EXERCISE_WEEKLY_MODERATE_VIGOROUS_MAX_VALUE = 24*7*60;


//enum {
//    GenderTypeMale = 0,
//    GenderTypeFemale
//};
//typedef NSUInteger GenderType;

typedef enum {
    GenderTypeMale = 0,
    GenderTypeFemale
} GenderType;
//typedef NSUInteger GenderType;

typedef enum {
    BGUnitMMOL= 0,
    BGUnitMG
} BGUnit;
//typedef NSUInteger BGUnit;

typedef enum {
    MUnitMetric = 0,
    MUnitImperial
} MeasureUnit;
//typedef NSUInteger MeasureUnit;

typedef enum {
    BMIUnderweight =0, //= <18.5
    BMINormalWeight, // = 18.5–24.9
    BMIOverWeight, // = 25–29.9
    BMIObesity // = BMI of 30 or greater
} BMICategory;
//typedef NSUInteger BMICategory;

typedef enum {
    MealTypeSnack = 0,
    MealTypeBreakfast,
    MealTypeLunch,
    MealTypeDinner
} MealType;

typedef enum {
    MealCreatedByQuickInput = 0,
    MealCreatedBySearch
} MealCreatedType;

typedef enum {
    FoodItemCreationTypeQuickInput = 0,
    FoodItemCreationTypeSearch,
    FoodItemCreationTypeBarcode,
    FoodItemCreationTypeManualInput,
    FoodItemCreationTypeOnlineSearch
} FoodItemCreationType;

typedef enum {
    TimeIntervalTypeWeek = 0,
    TimeIntervalTypeMonth,
    TimeIntervalType3Months,
    TimeIntervalType6Months
} TimeIntervalType;

typedef enum {
    GraphDataTypeAverageMealScore = 0,
    GraphDataTypeExerciesMinutes,
    GraphDataTypeDailyCalories,
    GraphDataTypeBloodGlucose,
    GraphDataTypeWeight
} GraphDataType;

enum {
    UnitViewControllerGlucoseDisplayMode = 0,
    UnitViewControllerWeightDisplayMode
};
typedef NSUInteger UnitViewControllerDisplayMode;

static NSString *const BGUNIT_DISPLAY_MMOL = @"mmol/L";
static NSString *const BGUNIT_DISPLAY_MG = @"mg/dL";
static NSString *const MUNIT_DISPLAY_METRIC = @"Metric (kg, cm)";
static NSString *const MUNIT_DISPLAY_IMPERIAL = @"Imperial (lbs, ft/in)";
static NSString *const GENDER_DISPLAY_MALE = @"Male";
static NSString *const GENDER_DISPLAY_FEMALE = @"Female";
static NSString *const HEIGHT_DISPLAY_METRIC = @"Height (cm)";
static NSString *const HEIGHT_DISPLAY_IMPERIAL = @"Height (feet, inches)";
static NSString *const WEIGHT_DISPLAY_METRIC = @"kg";
static NSString *const WEIGHT_DISPLAY_IMPERIAL = @"lbs";
static NSString *const BMI_WAIST_DISPLAY_METRIC = @"BMI and Waist (cm)";
static NSString *const BMI_WAIST_DISPLAY_IMPERIAL = @"BMI and Waist (inches)";

#pragma mark - actionable URL 

static NSString *const LOCAL_ACTION_ADD_REMINDER = @"local://add_reminder";
static NSString *const LOCAL_ACTION_ADD_REMINDER_EXERCISE = @"local://add_reminder_exercise";
static NSString *const LOCAL_ACTION_ADD_REMINDER_MEDICATION = @"local://add_reminder_medication";
static NSString *const LOCAL_ACTION_ADD_MEAL = @"local://add_meal";
static NSString *const LOCAL_ACTION_ADD_MEAL_BY_PHOTO = @"local://add_meal_by_photo";
static NSString *const LOCAL_ACTION_EDIT_PROFILE = @"local://edit_profile";
static NSString *const LOCAL_ACTION_CONTACT_US = @"local://contact_us";
static NSString *const LOCAL_ACTION_SET_GOAL = @"local://set_goal";




#pragma mark - AppDelegate

static NSString *const APP_DELEGATE_STORYBOARD_NAME = @"Main";
static NSString *const APP_DELEGATE_REGISTER_LOGIN_VIEW_CONTROLLER_ID = @"registerLoginViewController";
static NSString *const APP_DELEGATE_MAIN_TAB_BAR_CONTROLLER_ID = @"mainTabBarController";
static NSString *const APP_DELEGATE_SETTINGS_NAV_CONTROLLER_ID = @"settingsNavigationViewController";

static NSUInteger const APP_MAX_INTRO_SHOWN_COUNT = 2;

#import "ServicesConstants.h"
#import "GraphConstants.h"

#endif
