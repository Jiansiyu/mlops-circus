CREATE TABLE IF NOT EXISTS public.experiments
(
    experiment_id integer NOT NULL DEFAULT nextval('experiments_experiment_id_seq'::regclass),
    name character varying(256) COLLATE pg_catalog."default" NOT NULL,
    artifact_location character varying(256) COLLATE pg_catalog."default",
    lifecycle_stage character varying(32) COLLATE pg_catalog."default",
    creation_time bigint,
    last_update_time bigint,
    CONSTRAINT experiment_pk PRIMARY KEY (experiment_id),
    CONSTRAINT experiments_name_key UNIQUE (name),
    CONSTRAINT experiments_lifecycle_stage CHECK (lifecycle_stage::text = ANY (ARRAY['active'::character varying, 'deleted'::character varying]::text[]))
);

CREATE TABLE IF NOT EXISTS public.latest_metrics
(
    key character varying(250) COLLATE pg_catalog."default" NOT NULL,
    value double precision NOT NULL,
    "timestamp" bigint,
    step bigint NOT NULL,
    is_nan boolean NOT NULL,
    run_uuid character varying(32) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT latest_metric_pk PRIMARY KEY (key, run_uuid),
    CONSTRAINT latest_metrics_run_uuid_fkey FOREIGN KEY (run_uuid)
        REFERENCES public.runs (run_uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.metrics
(
    key character varying(250) COLLATE pg_catalog."default" NOT NULL,
    value double precision NOT NULL,
    "timestamp" bigint NOT NULL,
    run_uuid character varying(32) COLLATE pg_catalog."default" NOT NULL,
    step bigint NOT NULL DEFAULT '0'::bigint,
    is_nan boolean NOT NULL DEFAULT false,
    CONSTRAINT metric_pk PRIMARY KEY (key, "timestamp", step, run_uuid, value, is_nan),
    CONSTRAINT metrics_run_uuid_fkey FOREIGN KEY (run_uuid)
        REFERENCES public.runs (run_uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);



CREATE TABLE IF NOT EXISTS public.model_version_tags
(
    key character varying(250) COLLATE pg_catalog."default" NOT NULL,
    value character varying(5000) COLLATE pg_catalog."default",
    name character varying(256) COLLATE pg_catalog."default" NOT NULL,
    version integer NOT NULL,
    CONSTRAINT model_version_tag_pk PRIMARY KEY (key, name, version),
    CONSTRAINT model_version_tags_name_version_fkey FOREIGN KEY (version, name)
        REFERENCES public.model_versions (version, name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.model_versions
(
    name character varying(256) COLLATE pg_catalog."default" NOT NULL,
    version integer NOT NULL,
    creation_time bigint,
    last_updated_time bigint,
    description character varying(5000) COLLATE pg_catalog."default",
    user_id character varying(256) COLLATE pg_catalog."default",
    current_stage character varying(20) COLLATE pg_catalog."default",
    source character varying(500) COLLATE pg_catalog."default",
    run_id character varying(32) COLLATE pg_catalog."default",
    status character varying(20) COLLATE pg_catalog."default",
    status_message character varying(500) COLLATE pg_catalog."default",
    run_link character varying(500) COLLATE pg_catalog."default",
    CONSTRAINT model_version_pk PRIMARY KEY (name, version),
    CONSTRAINT model_versions_name_fkey FOREIGN KEY (name)
        REFERENCES public.registered_models (name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.params
(
    key character varying(250) COLLATE pg_catalog."default" NOT NULL,
    value character varying(500) COLLATE pg_catalog."default" NOT NULL,
    run_uuid character varying(32) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT param_pk PRIMARY KEY (key, run_uuid),
    CONSTRAINT params_run_uuid_fkey FOREIGN KEY (run_uuid)
        REFERENCES public.runs (run_uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.registered_model_tags
(
    key character varying(250) COLLATE pg_catalog."default" NOT NULL,
    value character varying(5000) COLLATE pg_catalog."default",
    name character varying(256) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT registered_model_tag_pk PRIMARY KEY (key, name),
    CONSTRAINT registered_model_tags_name_fkey FOREIGN KEY (name)
        REFERENCES public.registered_models (name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.registered_models
(
    name character varying(256) COLLATE pg_catalog."default" NOT NULL,
    creation_time bigint,
    last_updated_time bigint,
    description character varying(5000) COLLATE pg_catalog."default",
    CONSTRAINT registered_model_pk PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS public.runs
(
    run_uuid character varying(32) COLLATE pg_catalog."default" NOT NULL,
    name character varying(250) COLLATE pg_catalog."default",
    source_type character varying(20) COLLATE pg_catalog."default",
    source_name character varying(500) COLLATE pg_catalog."default",
    entry_point_name character varying(50) COLLATE pg_catalog."default",
    user_id character varying(256) COLLATE pg_catalog."default",
    status character varying(9) COLLATE pg_catalog."default",
    start_time bigint,
    end_time bigint,
    source_version character varying(50) COLLATE pg_catalog."default",
    lifecycle_stage character varying(20) COLLATE pg_catalog."default",
    artifact_uri character varying(200) COLLATE pg_catalog."default",
    experiment_id integer,
    deleted_time bigint,
    CONSTRAINT run_pk PRIMARY KEY (run_uuid),
    CONSTRAINT runs_experiment_id_fkey FOREIGN KEY (experiment_id)
        REFERENCES public.experiments (experiment_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT source_type CHECK (source_type::text = ANY (ARRAY['NOTEBOOK'::character varying, 'JOB'::character varying, 'LOCAL'::character varying, 'UNKNOWN'::character varying, 'PROJECT'::character varying]::text[])),
    CONSTRAINT runs_lifecycle_stage CHECK (lifecycle_stage::text = ANY (ARRAY['active'::character varying, 'deleted'::character varying]::text[])),
    CONSTRAINT runs_status_check CHECK (status::text = ANY (ARRAY['SCHEDULED'::character varying, 'FAILED'::character varying, 'FINISHED'::character varying, 'RUNNING'::character varying, 'KILLED'::character varying]::text[]))
);

CREATE TABLE IF NOT EXISTS public.tags
(
    key character varying(250) COLLATE pg_catalog."default" NOT NULL,
    value character varying(5000) COLLATE pg_catalog."default",
    run_uuid character varying(32) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tag_pk PRIMARY KEY (key, run_uuid),
    CONSTRAINT tags_run_uuid_fkey FOREIGN KEY (run_uuid)
        REFERENCES public.runs (run_uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
