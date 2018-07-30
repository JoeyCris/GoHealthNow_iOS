//
//  ServicesConstants.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-20.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_ServicesConstants_h
#define GlucoGuide_ServicesConstants_h

#define  CustomErrorDomain @"com.glucoguide.error_domain"

typedef enum {
    AppTypeGlucoGuide = 0,
    AppTypeGoHealthNow
} AppType;

typedef enum {
    AppLanguageEn = 0,
    AppLanguageFr
} AppLanguage;

typedef enum {
    XDefultFailed = -1000,
    XConnectionFailed,
    XAuthenticateFailed,
    XNotLoggedIn
} CustomErrorCode;
//#define XDefultFailed -1000



static NSString * const KEY_USERNAME_PASSWORD = @"com.gg.user.password";
static NSString * const KEY_USERNAME = @"email";
static NSString * const KEY_PASSWORD = @"password";
static NSString * const KEY_USERID = @"userid";

static NSString * const SERVER_DATE_FORMATE = @"yyyy-MM-dd'T'HH:mm:ssZ";
static NSString * const SERVER_RESPONSE_FIELD_RETCODE = @"retCode";
static NSString * const SERVER_RESPONSE_FIELD_DATA = @"data";
static NSString * const SERVER_RESPONSE_SUCCESS = @"success";

typedef enum {
    GGMessageTypePost = 1,
    GGMessageTypeMultiPost
} GGServerMessageType;

#pragma mark - PhotoUpload

static NSString * const PHOTO_CACHED_DIR = @"cachedPhoto";
static NSString * const PHOTO_UPLOAD_DATE_FORMATE = @"yyyyMMdd_HHmmss"; //20141024_123542
static NSString * const PHOTO_UPLOAD_PARA_DATE = @"date";
static NSString * const PHOTO_UPLOAD_PARA_MEALPHOTO = @"meal_photo";
static NSString * const PHOTO_UPLOAD_PARA_TYPE = @"image/jpeg";
static NSString * const PHOTO_UPLOAD_PARA_USERID = @"user_id";
static NSString * const PHOTO_UPLOAD_PARA_NOTE = @"image_question";
static NSString * const PHOTO_UPLOAD_PARA_FOREXPERT = @"expert_review";
static NSString * const PHOTO_UPLOAD_PARA_PHOTOTYPE = @"photo_type";
static NSString * const PHOTO_UPLOAD_PARA_PHOTONAME = @"photo_name";

static NSString * const BRAND_CACHED_DIR = @"branding";

static NSString * const AUDIO_CACHED_DIR = @"cachedAudio";

#pragma mark - Progress

typedef enum {
    SummaryPeroidDaily = 0,
    SummaryPeroidWeekly,
    SummaryPeroidMonthly
} SummaryPeroidType;

#pragma mark - User

static NSString * const IMPERIAL_UNIT_HEIGHT_FEET = @"feet";
static NSString * const IMPERIAL_UNIT_HEIGHT_INCHES = @"inches";

#pragma mark - GGUtils

static NSString * const WEEK_START_DATE_KEY = @"weekStartDate";
static NSString * const WEEK_END_DATE_KEY = @"weekEndDate";

#pragma mark - MealCalculator

static float const FEMALE_BMR_CONSTANT = 447.593;
static float const FEMALE_BMR_WEIGHT_CONSTANT = 9.247;
static float const FEMALE_BMR_HEIGHT_CONSTANT = 3.098;
static float const FEMALE_BMR_AGE_CONSTANT = 4.330;
static float const MALE_BMR_CONSTANT = 88.362;
static float const MALE_BMR_WEIGHT_CONSTANT = 13.397;
static float const MALE_BMR_HEIGHT_CONSTANT = 4.799;
static float const MALE_BMR_AGE_CONSTANT = 5.677;

static NSString * const MC_NUTRITION_KEY_NETCARB = @"netCarb";
static NSString * const MC_NUTRITION_KEY_CARB = @"carb";
static NSString * const MC_NUTRITION_KEY_FAT = @"fat";
static NSString * const MC_NUTRITION_KEY_PRO = @"pro";
static NSString * const MC_NUTRITION_KEY_SUG = @"sugar";
static NSString * const MC_NUTRITION_KEY_CAL = @"cal";
static NSString * const MC_NUTRITION_KEY_FIB = @"fibre";
static NSString * const MC_NUTRITION_KEY_STARCH = @"starch";
static NSString * const MC_NUTRITION_KEY_SATUREDFAT = @"saturedFat";
static NSString * const MC_NUTRITION_KEY_TRANSFAT = @"transFat";
static NSString * const MC_NUTRITION_KEY_SODIUM = @"sodium";
static NSString * const MC_NUTRITION_KEY_UNHEALTHYFAT = @"unhealthyFat";

static NSString * const MC_NUTRITION_KEY_CAL_RATIOS = @"calRatios";
static NSString * const MC_NUTRITION_KEY_AMOUNTS = @"amounts";

static NSString * const MC_SCORE_KEY = @"score";
static NSString * const MC_ADJUST_STATEMENTS_KEY = @"adjustmentStatements";
static NSString * const MC_NUTRITION_FACTS_KEY = @"nutritionFacts";

static NSString * const MACRO_NUTRIENT_ESTIMATION_FILE = @"MacroNutrientEstimation";

static NSString * const MACRO_NEXML_MEAL_SCORING_RANGEFACTOR = @"_rangeFactor";
static NSString * const MACRO_NEXML_MEAL_SCORING_MAXPROGRESS = @"_maxProgress";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD = @"LogMethod";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL = @"Meal";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE = @"_logType";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE_ATTR_QUCIK_ESTIMATE = @"0";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE_ATTR_SEARCH = @"1";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE = @"_mealType";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK = @"0";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST = @"1";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH = @"2";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER = @"3";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION = @"Nutrition";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME = @"_name";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CALORIES = @"Calories";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CARBS = @"Carbs";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FATS = @"Fats";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_PROTEIN = @"Protein";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FIBER = @"Fiber";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_UNHEALTHYFAT = @"UnHealthyFat";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_SODIUM = @"Sodium";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_SUGAR_RATIO = @"SugarRatio";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_CALSPERUNIT = @"_calsPerUnit";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_CALSPERUNIT_KCALS = @"kcals";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_CALSPERUNIT_G = @"g";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_UNIT = @"_unit";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO = @"_targetRatio";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO = @"_subTargetRatio";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_VIEWTYPE = @"_viewType";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT = @"_adequateStatement";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT = @"_warningStatement";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG = @"warningStatement";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG = @"adequateStatement";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_LOWBOUND = @"_lowBound";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND = @"_highBound";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ATTR = @"__text";

static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT = @"statement";
static NSString * const MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG = @"flag";

static NSString * const MC_XML_TAG_SCORE_RULE = @"ScoreRule";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR = @"_name";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_CAL = @"Calroies";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_CARB = @"CalroiesCarb";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_SUGAR = @"CalroiesSugar";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_PRO = @"CalroiesPro";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_FAT = @"CalroiesFat";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_FIBER = @"FibreAmount";
//
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_SODIUM = @"SodiumAmount";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_SATUREFAT = @"CalroiesSatureFat";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_TRANSFAT = @"CalroiesTransFat";
static NSString * const MC_XML_SCORE_RULE_NAME_ATTR_UNHEALTHYFAT = @"CalroiesUnHealthyFat";

static NSString * const MC_XML_SCORE_RULE_TYPE_ATTR = @"_type";
static NSString * const MC_XML_TAG_LOWER_BOUND = @"LowerBound";
static NSString * const MC_XML_TAG_UPPER_BOUND = @"UpperBound";
static NSString * const MC_XML_TAG_ADJUSTMENT = @"Adjustment";

static NSString * const MC_XML_TAG_POINTSTATEMENT = @"PointStatement";
//static NSString * const MC_XML_ADJUSTMENT_AMOUNT_ATTR = @"_amount";
//static NSString * const MC_XML_ADJUSTMENT_SCORE_ATTR = @"_score";
//static NSString * const MC_XML_ADJUSTMENT_TEXT = @"__text";

static NSString * const MC_XML_ADJUSTMENT_HIGH_ATTR = @"_high";
static NSString * const MC_XML_ADJUSTMENT_LOW_ATTR = @"_low";
static NSString * const MC_XML_ADJUSTMENT_INTERVAL_ATTR = @"_interval";
static NSString * const MC_XML_ADJUSTMENT_SCORE_ATTR = @"_score";
static NSString * const MC_XML_ADJUSTMENT_INF_VALUE = @"inf";
static NSString * const MC_XML_ADJUSTMENT_MINUS_INF_VALUE = @"-inf";

static NSString * const MC_XML_STATEMENT_HIGH_ATTR = @"_high";
static NSString * const MC_XML_STATEMENT_LOW_ATTR = @"_low";
static NSString * const MC_XML_STATEMENT_TYPE_ATTR = @"_type";
static NSString * const MC_XML_STATEMENT_TEXT = @"__text";
static NSString * const MC_XML_STATEMENT_SCORETYPE_HIGH = @"high";
static NSString * const MC_XML_STATEMENT_SCORETYPE_BELOW = @"below";
static NSString * const MC_XML_STATEMENT_SCORETYPE_BALANCE = @"balance";

enum {
    QuickEstimateValueTypeIdeal = 0,
    QuickEstimateValueTypeZero
};
typedef NSUInteger QuickEstimateValueType;

#pragma mark - Insulins
static NSString * const MACRO_INSULIN_XML_ID_ATTR = @"_ID";
static NSString * const MACRO_INSULIN_XML_NAME_ATTR = @"_Name";

#pragma mark - GlucoseRecord
static NSString * const MACRO_FASTBG_NAME_ATTR = @"fastBG";
static NSString * const MACRO_FASTBG_RECORDEDDAY_ATTR = @"recordedDay";
static NSString * const MACRO_BG_ROWS_ATTR = @"rows";
static NSString * const MACRO_BG_CATEGORY_ATTR = @"category";

#pragma mark - BPRecord
static NSString * const MACRO_BP_ROWS_ATTR = @"rows";
static NSString * const MACRO_BP_CATEGORY_ATTR = @"category";

#pragma mark - ExerciseRecord
static NSString * const MACRO_EXERCISE_CATEGORY_ATTR = @"category";
static NSString * const MACRO_EXERCISE_ROWS_ATTR = @"rows";

#pragma mark - WeightRecord
static NSString * const MACRO_WEIGHT_NAME_ATTR = @"weight";
static NSString * const MACRO_WEIGHT_RECORDEDDAY_ATTR = @"recordedDay";

#pragma mark - A1C
static NSString * const MACRO_A1C_NAME_ATTR = @"a1c";
static NSString * const MACRO_A1C_RECORDEDDAY_ATTR = @"recordedDay";

#pragma mark - RecommendationRecord
typedef enum {
    ImageLocationLocal = 0,
    ImageLocationRemote
} ImageLocation;

#pragma mark - NoteRecord
typedef enum {
    NoteTypeDiet = 0,
    NoteTypeExercise,
    NoteTypeGlucose,
    NoteTypeWeight,
    NoteTypeOthers
} NoteType;

#pragma mark - GlucoguideAPI
typedef enum {
    UploadPhotoOnly = 0,
    PhotoForFoodRecognition,
    PhotoForExerciseRecognition
} UploadPhotoType;

//for food item online search
static NSString * const ERROR_DICT_DESCRIPTION = @"description";

#pragma mark - HttpClient
static NSString * const FORM_PARAMETER_NAME = @"name";
static NSString * const FORM_PARAMETER_VALUE = @"value";
static NSString * const FORM_PARAMETER_ISFILE = @"isFile";
static NSString * const FORM_PARAMETER_MIMETYPE = @"mimeType";

static NSString * const HTTP_MESSAGE_NETWORK_UNAVAILABLE = @"Failed to connect to server. Please check your network settings";

static NSString * const SERVER_MESSAGE_UNKNOWN_ERROR = @"Unknown Server Error";

#endif
