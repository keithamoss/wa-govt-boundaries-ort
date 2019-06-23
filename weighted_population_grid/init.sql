CREATE TABLE meshblock_2016_counts_geo AS
	SELECT mb_counts.*, mb_wa.geom FROM meshblocks_2016_wa AS mb_wa, meshblocks_2016_counts AS mb_counts WHERE mb_wa.geom IS NOT NULL AND mb_wa.mb_code16 = mb_counts.mb_code_2016;

CREATE INDEX "meshblock_2016_counts_geo_geom_idx" ON "public"."meshblock_2016_counts_geo" USING GIST ("geom");