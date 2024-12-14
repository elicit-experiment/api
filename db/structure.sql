SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: chaos_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chaos_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    session_guid character varying NOT NULL,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    phase_definition_id integer,
    trial_definition_id integer,
    protocol_user_id integer,
    study_result_id integer,
    experiment_id integer,
    stage_id integer,
    trial_result_id integer,
    preview boolean,
    url character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: chaos_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chaos_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chaos_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chaos_sessions_id_seq OWNED BY public.chaos_sessions.id;


--
-- Name: components; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.components (
    id integer NOT NULL,
    definition_data character varying,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    phase_definition_id integer NOT NULL,
    trial_definition_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying
);


--
-- Name: components_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.components_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.components_id_seq OWNED BY public.components.id;


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_files (
    id integer NOT NULL,
    file character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: media_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_files_id_seq OWNED BY public.media_files.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: phase_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phase_definitions (
    id integer NOT NULL,
    definition_data character varying,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    trial_ordering character varying
);


--
-- Name: phase_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phase_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phase_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phase_definitions_id_seq OWNED BY public.phase_definitions.id;


--
-- Name: phase_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phase_orders (
    id integer NOT NULL,
    sequence_data character varying,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: phase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phase_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phase_orders_id_seq OWNED BY public.phase_orders.id;


--
-- Name: protocol_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocol_definitions (
    id integer NOT NULL,
    name character varying,
    version integer,
    type character varying,
    summary character varying,
    description character varying,
    definition_data character varying,
    active boolean DEFAULT false NOT NULL,
    study_definition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: protocol_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.protocol_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: protocol_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.protocol_definitions_id_seq OWNED BY public.protocol_definitions.id;


--
-- Name: protocol_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocol_users (
    id integer NOT NULL,
    user_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    group_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: protocol_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.protocol_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: protocol_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.protocol_users_id_seq OWNED BY public.protocol_users.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: stimuli; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stimuli (
    id integer NOT NULL,
    definition_data character varying,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    phase_definition_id integer NOT NULL,
    trial_definition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stimuli_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stimuli_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stimuli_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stimuli_id_seq OWNED BY public.stimuli.id;


--
-- Name: study_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_definitions (
    id integer NOT NULL,
    title character varying,
    description character varying,
    principal_investigator_user_id integer NOT NULL,
    version integer,
    data text,
    lock_question integer,
    enable_previous integer,
    no_of_trials integer,
    trials_completed integer,
    footer_label text,
    redirect_close_on_url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "AllowAnonymousUsers" boolean,
    "ShowInStudyList" boolean,
    allow_anonymous_users boolean,
    show_in_study_list boolean,
    max_anonymous_users integer,
    auto_created_user_count integer DEFAULT 0,
    max_auto_created_users integer DEFAULT 0,
    max_concurrent_users integer,
    searchable tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('english'::regconfig, (COALESCE(description, ''::character varying))::text), 'B'::"char"))) STORED
);


--
-- Name: study_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_definitions_id_seq OWNED BY public.study_definitions.id;


--
-- Name: study_result_contexts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_contexts (
    id integer NOT NULL,
    "timestamp" timestamp without time zone,
    context_type text,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_result_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_contexts_id_seq OWNED BY public.study_result_contexts.id;


--
-- Name: study_result_data_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_data_points (
    id integer NOT NULL,
    stage_id integer NOT NULL,
    protocol_user_id integer,
    phase_definition_id integer,
    trial_definition_id integer,
    component_id integer,
    kind character varying,
    point_type character varying,
    value character varying,
    method character varying,
    datetime timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    entity_type character varying,
    deleted boolean DEFAULT false NOT NULL
);


--
-- Name: study_result_data_points_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_data_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_data_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_data_points_id_seq OWNED BY public.study_result_data_points.id;


--
-- Name: study_result_experiments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_experiments (
    id integer NOT NULL,
    study_result_id integer NOT NULL,
    protocol_user_id integer NOT NULL,
    current_stage_id integer,
    num_stages_completed integer,
    num_stages_remaining integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    custom_parameters jsonb,
    client_info jsonb
);


--
-- Name: study_result_experiments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_experiments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_experiments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_experiments_id_seq OWNED BY public.study_result_experiments.id;


--
-- Name: study_result_stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_stages (
    id integer NOT NULL,
    experiment_id integer NOT NULL,
    protocol_user_id integer NOT NULL,
    phase_definition_id integer NOT NULL,
    last_completed_trial integer,
    current_trial integer,
    num_trials integer,
    context_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    client_info jsonb
);


--
-- Name: study_result_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_stages_id_seq OWNED BY public.study_result_stages.id;


--
-- Name: study_result_study_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_study_results (
    id integer NOT NULL,
    study_definition_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    completed_at timestamp without time zone
);


--
-- Name: study_result_study_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_study_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_study_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_study_results_id_seq OWNED BY public.study_result_study_results.id;


--
-- Name: study_result_time_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_time_series (
    id integer NOT NULL,
    stage_id integer,
    study_definition_id integer,
    protocol_definition_id integer,
    phase_definition_id integer,
    component_id integer,
    file character varying,
    schema character varying,
    schema_metadata character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_result_time_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_time_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_time_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_time_series_id_seq OWNED BY public.study_result_time_series.id;


--
-- Name: study_result_trial_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_result_trial_results (
    id integer NOT NULL,
    experiment_id integer NOT NULL,
    protocol_user_id integer NOT NULL,
    phase_definition_id integer NOT NULL,
    trial_definition_id integer NOT NULL,
    session_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    completed_at timestamp without time zone
);


--
-- Name: study_result_trial_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_result_trial_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_result_trial_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_result_trial_results_id_seq OWNED BY public.study_result_trial_results.id;


--
-- Name: trial_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trial_definitions (
    id integer NOT NULL,
    definition_data character varying,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    phase_definition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    description character varying
);


--
-- Name: trial_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trial_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trial_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trial_definitions_id_seq OWNED BY public.trial_definitions.id;


--
-- Name: trial_order_selection_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trial_order_selection_mappings (
    id integer NOT NULL,
    trial_order_id integer,
    user_id integer,
    phase_definition_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trial_order_selection_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trial_order_selection_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trial_order_selection_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trial_order_selection_mappings_id_seq OWNED BY public.trial_order_selection_mappings.id;


--
-- Name: trial_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trial_orders (
    id integer NOT NULL,
    sequence_data character varying,
    study_definition_id integer NOT NULL,
    protocol_definition_id integer NOT NULL,
    phase_definition_id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trial_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trial_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trial_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trial_orders_id_seq OWNED BY public.trial_orders.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    anonymous boolean,
    role character varying,
    username character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: chaos_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chaos_sessions ALTER COLUMN id SET DEFAULT nextval('public.chaos_sessions_id_seq'::regclass);


--
-- Name: components id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.components ALTER COLUMN id SET DEFAULT nextval('public.components_id_seq'::regclass);


--
-- Name: media_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_files ALTER COLUMN id SET DEFAULT nextval('public.media_files_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: phase_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_definitions ALTER COLUMN id SET DEFAULT nextval('public.phase_definitions_id_seq'::regclass);


--
-- Name: phase_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_orders ALTER COLUMN id SET DEFAULT nextval('public.phase_orders_id_seq'::regclass);


--
-- Name: protocol_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol_definitions ALTER COLUMN id SET DEFAULT nextval('public.protocol_definitions_id_seq'::regclass);


--
-- Name: protocol_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol_users ALTER COLUMN id SET DEFAULT nextval('public.protocol_users_id_seq'::regclass);


--
-- Name: stimuli id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stimuli ALTER COLUMN id SET DEFAULT nextval('public.stimuli_id_seq'::regclass);


--
-- Name: study_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_definitions ALTER COLUMN id SET DEFAULT nextval('public.study_definitions_id_seq'::regclass);


--
-- Name: study_result_contexts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_contexts ALTER COLUMN id SET DEFAULT nextval('public.study_result_contexts_id_seq'::regclass);


--
-- Name: study_result_data_points id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_data_points ALTER COLUMN id SET DEFAULT nextval('public.study_result_data_points_id_seq'::regclass);


--
-- Name: study_result_experiments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_experiments ALTER COLUMN id SET DEFAULT nextval('public.study_result_experiments_id_seq'::regclass);


--
-- Name: study_result_stages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_stages ALTER COLUMN id SET DEFAULT nextval('public.study_result_stages_id_seq'::regclass);


--
-- Name: study_result_study_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_study_results ALTER COLUMN id SET DEFAULT nextval('public.study_result_study_results_id_seq'::regclass);


--
-- Name: study_result_time_series id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_time_series ALTER COLUMN id SET DEFAULT nextval('public.study_result_time_series_id_seq'::regclass);


--
-- Name: study_result_trial_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_trial_results ALTER COLUMN id SET DEFAULT nextval('public.study_result_trial_results_id_seq'::regclass);


--
-- Name: trial_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_definitions ALTER COLUMN id SET DEFAULT nextval('public.trial_definitions_id_seq'::regclass);


--
-- Name: trial_order_selection_mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_order_selection_mappings ALTER COLUMN id SET DEFAULT nextval('public.trial_order_selection_mappings_id_seq'::regclass);


--
-- Name: trial_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_orders ALTER COLUMN id SET DEFAULT nextval('public.trial_orders_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: chaos_sessions chaos_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chaos_sessions
    ADD CONSTRAINT chaos_sessions_pkey PRIMARY KEY (id);


--
-- Name: components components_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.components
    ADD CONSTRAINT components_pkey PRIMARY KEY (id);


--
-- Name: media_files media_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: phase_definitions phase_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_definitions
    ADD CONSTRAINT phase_definitions_pkey PRIMARY KEY (id);


--
-- Name: phase_orders phase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_orders
    ADD CONSTRAINT phase_orders_pkey PRIMARY KEY (id);


--
-- Name: protocol_definitions protocol_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol_definitions
    ADD CONSTRAINT protocol_definitions_pkey PRIMARY KEY (id);


--
-- Name: protocol_users protocol_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol_users
    ADD CONSTRAINT protocol_users_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: stimuli stimuli_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stimuli
    ADD CONSTRAINT stimuli_pkey PRIMARY KEY (id);


--
-- Name: study_definitions study_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_definitions
    ADD CONSTRAINT study_definitions_pkey PRIMARY KEY (id);


--
-- Name: study_result_contexts study_result_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_contexts
    ADD CONSTRAINT study_result_contexts_pkey PRIMARY KEY (id);


--
-- Name: study_result_data_points study_result_data_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_data_points
    ADD CONSTRAINT study_result_data_points_pkey PRIMARY KEY (id);


--
-- Name: study_result_experiments study_result_experiments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_experiments
    ADD CONSTRAINT study_result_experiments_pkey PRIMARY KEY (id);


--
-- Name: study_result_stages study_result_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_stages
    ADD CONSTRAINT study_result_stages_pkey PRIMARY KEY (id);


--
-- Name: study_result_study_results study_result_study_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_study_results
    ADD CONSTRAINT study_result_study_results_pkey PRIMARY KEY (id);


--
-- Name: study_result_time_series study_result_time_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_time_series
    ADD CONSTRAINT study_result_time_series_pkey PRIMARY KEY (id);


--
-- Name: study_result_trial_results study_result_trial_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_result_trial_results
    ADD CONSTRAINT study_result_trial_results_pkey PRIMARY KEY (id);


--
-- Name: trial_definitions trial_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_definitions
    ADD CONSTRAINT trial_definitions_pkey PRIMARY KEY (id);


--
-- Name: trial_order_selection_mappings trial_order_selection_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_order_selection_mappings
    ADD CONSTRAINT trial_order_selection_mappings_pkey PRIMARY KEY (id);


--
-- Name: trial_orders trial_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_orders
    ADD CONSTRAINT trial_orders_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_chaos_sessions_on_experiment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_experiment_id ON public.chaos_sessions USING btree (experiment_id);


--
-- Name: index_chaos_sessions_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_phase_definition_id ON public.chaos_sessions USING btree (phase_definition_id);


--
-- Name: index_chaos_sessions_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_protocol_definition_id ON public.chaos_sessions USING btree (protocol_definition_id);


--
-- Name: index_chaos_sessions_on_protocol_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_protocol_user_id ON public.chaos_sessions USING btree (protocol_user_id);


--
-- Name: index_chaos_sessions_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_stage_id ON public.chaos_sessions USING btree (stage_id);


--
-- Name: index_chaos_sessions_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_study_definition_id ON public.chaos_sessions USING btree (study_definition_id);


--
-- Name: index_chaos_sessions_on_study_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_study_result_id ON public.chaos_sessions USING btree (study_result_id);


--
-- Name: index_chaos_sessions_on_trial_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_trial_definition_id ON public.chaos_sessions USING btree (trial_definition_id);


--
-- Name: index_chaos_sessions_on_trial_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_trial_result_id ON public.chaos_sessions USING btree (trial_result_id);


--
-- Name: index_chaos_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chaos_sessions_on_user_id ON public.chaos_sessions USING btree (user_id);


--
-- Name: index_components_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_components_on_phase_definition_id ON public.components USING btree (phase_definition_id);


--
-- Name: index_components_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_components_on_protocol_definition_id ON public.components USING btree (protocol_definition_id);


--
-- Name: index_components_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_components_on_study_definition_id ON public.components USING btree (study_definition_id);


--
-- Name: index_components_on_trial_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_components_on_trial_definition_id ON public.components USING btree (trial_definition_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_phase_definitions_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phase_definitions_on_protocol_definition_id ON public.phase_definitions USING btree (protocol_definition_id);


--
-- Name: index_phase_definitions_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phase_definitions_on_study_definition_id ON public.phase_definitions USING btree (study_definition_id);


--
-- Name: index_phase_orders_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phase_orders_on_protocol_definition_id ON public.phase_orders USING btree (protocol_definition_id);


--
-- Name: index_phase_orders_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phase_orders_on_study_definition_id ON public.phase_orders USING btree (study_definition_id);


--
-- Name: index_phase_orders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phase_orders_on_user_id ON public.phase_orders USING btree (user_id);


--
-- Name: index_protocol_definitions_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocol_definitions_on_study_definition_id ON public.protocol_definitions USING btree (study_definition_id);


--
-- Name: index_protocol_users_on_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocol_users_on_group_name ON public.protocol_users USING btree (group_name);


--
-- Name: index_protocol_users_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocol_users_on_protocol_definition_id ON public.protocol_users USING btree (protocol_definition_id);


--
-- Name: index_protocol_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocol_users_on_user_id ON public.protocol_users USING btree (user_id);


--
-- Name: index_stimuli_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stimuli_on_phase_definition_id ON public.stimuli USING btree (phase_definition_id);


--
-- Name: index_stimuli_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stimuli_on_protocol_definition_id ON public.stimuli USING btree (protocol_definition_id);


--
-- Name: index_stimuli_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stimuli_on_study_definition_id ON public.stimuli USING btree (study_definition_id);


--
-- Name: index_stimuli_on_trial_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stimuli_on_trial_definition_id ON public.stimuli USING btree (trial_definition_id);


--
-- Name: index_study_definitions_on_allow_anonymous_users; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_definitions_on_allow_anonymous_users ON public.study_definitions USING btree (allow_anonymous_users);


--
-- Name: index_study_definitions_on_principal_investigator_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_definitions_on_principal_investigator_user_id ON public.study_definitions USING btree (principal_investigator_user_id);


--
-- Name: index_study_definitions_on_searchable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_definitions_on_searchable ON public.study_definitions USING gin (searchable);


--
-- Name: index_study_definitions_on_show_in_study_list; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_definitions_on_show_in_study_list ON public.study_definitions USING btree (show_in_study_list);


--
-- Name: index_study_result_data_points_on_component_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_data_points_on_component_id ON public.study_result_data_points USING btree (component_id);


--
-- Name: index_study_result_data_points_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_data_points_on_phase_definition_id ON public.study_result_data_points USING btree (phase_definition_id);


--
-- Name: index_study_result_data_points_on_protocol_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_data_points_on_protocol_user_id ON public.study_result_data_points USING btree (protocol_user_id);


--
-- Name: index_study_result_data_points_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_data_points_on_stage_id ON public.study_result_data_points USING btree (stage_id);


--
-- Name: index_study_result_data_points_on_trial_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_data_points_on_trial_definition_id ON public.study_result_data_points USING btree (trial_definition_id);


--
-- Name: index_study_result_experiments_on_current_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_experiments_on_current_stage_id ON public.study_result_experiments USING btree (current_stage_id);


--
-- Name: index_study_result_experiments_on_protocol_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_experiments_on_protocol_user_id ON public.study_result_experiments USING btree (protocol_user_id);


--
-- Name: index_study_result_experiments_on_study_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_experiments_on_study_result_id ON public.study_result_experiments USING btree (study_result_id);


--
-- Name: index_study_result_stages_on_context_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_stages_on_context_id ON public.study_result_stages USING btree (context_id);


--
-- Name: index_study_result_stages_on_experiment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_stages_on_experiment_id ON public.study_result_stages USING btree (experiment_id);


--
-- Name: index_study_result_stages_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_stages_on_phase_definition_id ON public.study_result_stages USING btree (phase_definition_id);


--
-- Name: index_study_result_stages_on_protocol_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_stages_on_protocol_user_id ON public.study_result_stages USING btree (protocol_user_id);


--
-- Name: index_study_result_study_results_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_study_results_on_study_definition_id ON public.study_result_study_results USING btree (study_definition_id);


--
-- Name: index_study_result_study_results_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_study_results_on_user_id ON public.study_result_study_results USING btree (user_id);


--
-- Name: index_study_result_time_series_on_component_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_time_series_on_component_id ON public.study_result_time_series USING btree (component_id);


--
-- Name: index_study_result_time_series_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_time_series_on_phase_definition_id ON public.study_result_time_series USING btree (phase_definition_id);


--
-- Name: index_study_result_time_series_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_time_series_on_protocol_definition_id ON public.study_result_time_series USING btree (protocol_definition_id);


--
-- Name: index_study_result_time_series_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_time_series_on_stage_id ON public.study_result_time_series USING btree (stage_id);


--
-- Name: index_study_result_time_series_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_time_series_on_study_definition_id ON public.study_result_time_series USING btree (study_definition_id);


--
-- Name: index_study_result_trial_results_on_experiment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_trial_results_on_experiment_id ON public.study_result_trial_results USING btree (experiment_id);


--
-- Name: index_study_result_trial_results_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_trial_results_on_phase_definition_id ON public.study_result_trial_results USING btree (phase_definition_id);


--
-- Name: index_study_result_trial_results_on_protocol_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_trial_results_on_protocol_user_id ON public.study_result_trial_results USING btree (protocol_user_id);


--
-- Name: index_study_result_trial_results_on_trial_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_result_trial_results_on_trial_definition_id ON public.study_result_trial_results USING btree (trial_definition_id);


--
-- Name: index_trial_definitions_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_definitions_on_phase_definition_id ON public.trial_definitions USING btree (phase_definition_id);


--
-- Name: index_trial_definitions_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_definitions_on_protocol_definition_id ON public.trial_definitions USING btree (protocol_definition_id);


--
-- Name: index_trial_definitions_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_definitions_on_study_definition_id ON public.trial_definitions USING btree (study_definition_id);


--
-- Name: index_trial_order_selection_mappings_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_order_selection_mappings_on_phase_definition_id ON public.trial_order_selection_mappings USING btree (phase_definition_id);


--
-- Name: index_trial_order_selection_mappings_on_trial_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_order_selection_mappings_on_trial_order_id ON public.trial_order_selection_mappings USING btree (trial_order_id);


--
-- Name: index_trial_order_selection_mappings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_order_selection_mappings_on_user_id ON public.trial_order_selection_mappings USING btree (user_id);


--
-- Name: index_trial_orders_on_phase_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_orders_on_phase_definition_id ON public.trial_orders USING btree (phase_definition_id);


--
-- Name: index_trial_orders_on_protocol_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_orders_on_protocol_definition_id ON public.trial_orders USING btree (protocol_definition_id);


--
-- Name: index_trial_orders_on_study_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_orders_on_study_definition_id ON public.trial_orders USING btree (study_definition_id);


--
-- Name: index_trial_orders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_orders_on_user_id ON public.trial_orders USING btree (user_id);


--
-- Name: trial_order_selection_mappings fk_rails_8c4c7d984f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_order_selection_mappings
    ADD CONSTRAINT fk_rails_8c4c7d984f FOREIGN KEY (trial_order_id) REFERENCES public.trial_orders(id);


--
-- Name: trial_order_selection_mappings fk_rails_c5de20bf65; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_order_selection_mappings
    ADD CONSTRAINT fk_rails_c5de20bf65 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: trial_order_selection_mappings fk_rails_dd6e57ae7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_order_selection_mappings
    ADD CONSTRAINT fk_rails_dd6e57ae7e FOREIGN KEY (phase_definition_id) REFERENCES public.phase_definitions(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20230226012246'),
('20230226012108'),
('20190401150202'),
('20190330213835'),
('20190330213822'),
('20190212194548'),
('20190123180343'),
('20190120052807'),
('20190118161909'),
('20181218035443'),
('20181216113752'),
('20181210111808'),
('20181207091722'),
('20181207090515'),
('20170829210919');

