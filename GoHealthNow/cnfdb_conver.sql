CREATE TABLE "FOOD"(
	   id INTEGER PRIMARY KEY NOT NULL,
	   hierarchy TEXT,
	   subhierarchy TEXT,
	   name TEXT,
	   label INTEGER,
	   serving_size TEXT,
	   calories REAL,
	   total_fat REAL,
	   sat_fat REAL,
	   trans_fat REAL,
	   sodium REAL,
	   total_carbs REAL,
	   diet_fiber REAL,
	   sugars REAL,
	   protein REAL,
	   iron REAL
);

insert into Food select FD_ID as id, b.fd_sup_grp_nme as hierarchy, b.fd_grp_nme as subhierarchy, L_FD_NME as name, case  FD_LABEL when 'Not Given' then 0   when 'In Moderation' then 1 when 'Less Often' then 2 when 'More Often' then 3 end label, " 1 item (100g)" as serving_size, null, null, null, null, null, null, null, null, null, null from food_nm a, food_grp b where a.fd_grp_id = b.fd_grp_id and fd_id < 502111;



INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, b.nt_value calories, a.total_fat, a.sat_fat, a.trans_fat, a.sodium, a.total_carbs, a.diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 208;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, b.nt_value total_fat, a.sat_fat, a.trans_fat, a.sodium, a.total_carbs, a.diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 204;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, b.nt_value sat_fat, a.trans_fat, a.sodium, a.total_carbs, a.diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 606;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, b.nt_value trans_fat, a.sodium, a.total_carbs, a.diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 605;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, a.trans_fat, b.nt_value sodium, a.total_carbs, a.diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 307;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, a.trans_fat, a.sodium, b.nt_value total_carbs, a.diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 205;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, a.trans_fat, a.sodium, a.total_carbs, b.nt_value diet_fiber, a.sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 291;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, a.trans_fat, a.sodium, a.total_carbs, a.diet_fiber, b.nt_value sugars, a.protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 269;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, a.trans_fat, a.sodium, a.total_carbs, a.diet_fiber, a.sugars, b.nt_value protein, a.iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 203;

INSERT OR REPLACE INTO FOOD SELECT a.id, a.hierarchy, a.subhierarchy, a.name, a.label, a.serving_size, a.calories, a.total_fat, a.sat_fat, a.trans_fat, a.sodium, a.total_carbs, a.diet_fiber, a.sugars, a.protein, b.nt_value iron FROM FOOD a JOIN nt_amt b ON b.fd_id = a.id and b.nt_id = 303;

