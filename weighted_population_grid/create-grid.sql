DROP SEQUENCE mb_pop_grid_tmp_seq;
CREATE SEQUENCE mb_pop_grid_tmp_seq CYCLE;

DROP TABLE meshblock_2016_population_grid;
CREATE TABLE meshblock_2016_population_grid AS 
	WITH 
	constants (nclusters_per_mb, npoints_per_mb) as (
		values (10, 2000)
	),
	mb_pts AS (
		SELECT nextval('mb_pop_grid_tmp_seq'::regclass) AS gid, (ST_Dump(ST_GeneratePoints(geom, constants.npoints_per_mb))).geom AS geom, meshblock_2016_counts_geo.mb_code_2016, meshblock_2016_counts_geo.person
		FROM meshblock_2016_counts_geo, constants	),
	mb_pts_clustered AS (
		SELECT geom, mb_code_2016, person, ST_ClusterKMeans(geom, constants.nclusters_per_mb) OVER (PARTITION BY mb_code_2016) AS cluster FROM mb_pts, constants
	),
	mb_pts_grid AS (
		SELECT mb_code_2016, ST_Centroid(ST_collect(geom)) AS geom FROM mb_pts_clustered GROUP BY mb_code_2016, cluster
	)
	SELECT 
		mb_pts_grid.*,
		(SELECT (person::float / constants.nclusters_per_mb) FROM meshblock_2016_counts_geo AS mb_cnt WHERE mb_cnt.mb_code_2016 = mb_pts_grid.mb_code_2016) AS person,
		(SELECT (dwelling::float / constants.nclusters_per_mb) FROM meshblock_2016_counts_geo AS mb_cnt WHERE mb_cnt.mb_code_2016 = mb_pts_grid.mb_code_2016) AS dwelling
	FROM mb_pts_grid, constants;

CREATE INDEX "meshblock_2016_population_grid_mb_code_2016_idx" ON "public"."meshblock_2016_population_grid"("mb_code_2016");
CREATE INDEX "meshblock_2016_population_grid_geom_idx" ON "public"."meshblock_2016_population_grid" USING GIST ("geom");