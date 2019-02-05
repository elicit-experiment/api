CREATE TABLE IF NOT EXISTS "chaos_sessions" ("id" SERIAL PRIMARY KEY NOT NULL, "user_id" integer NOT NULL, "session_guid" varchar NOT NULL, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "phase_definition_id" integer, "trial_definition_id" integer, "protocol_user_id" integer, "study_result_id" integer, "experiment_id" integer, "stage_id" integer, "trial_result_id" integer, "preview" boolean, "url" varchar NOT NULL, "expires_at" timestamp NOT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE TABLE IF NOT EXISTS "components" ("id" SERIAL PRIMARY KEY NOT NULL, "definition_data" varchar, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "phase_definition_id" integer NOT NULL, "trial_definition_id" integer, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_components_on_phase_definition_id" ON "components" ("phase_definition_id");
CREATE INDEX "index_components_on_protocol_definition_id" ON "components" ("protocol_definition_id");
CREATE INDEX "index_components_on_study_definition_id" ON "components" ("study_definition_id");
CREATE INDEX "index_components_on_trial_definition_id" ON "components" ("trial_definition_id");
CREATE TABLE IF NOT EXISTS "media_files" ("id" SERIAL PRIMARY KEY NOT NULL, "file" varchar, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE TABLE IF NOT EXISTS "oauth_access_grants" ("id" SERIAL PRIMARY KEY NOT NULL, "resource_owner_id" integer NOT NULL, "application_id" integer NOT NULL, "token" varchar NOT NULL, "expires_in" integer NOT NULL, "redirect_uri" text NOT NULL, "created_at" timestamp NOT NULL, "revoked_at" timestamp, "scopes" varchar);
CREATE INDEX "index_oauth_access_grants_on_application_id" ON "oauth_access_grants" ("application_id");
CREATE UNIQUE INDEX "index_oauth_access_grants_on_token" ON "oauth_access_grants" ("token");
CREATE TABLE IF NOT EXISTS "oauth_access_tokens" ("id" SERIAL PRIMARY KEY NOT NULL, "resource_owner_id" integer, "application_id" integer, "token" varchar NOT NULL, "refresh_token" varchar, "expires_in" integer, "revoked_at" timestamp, "created_at" timestamp NOT NULL, "scopes" varchar, "previous_refresh_token" varchar DEFAULT '' NOT NULL);
CREATE INDEX "index_oauth_access_tokens_on_application_id" ON "oauth_access_tokens" ("application_id");
CREATE UNIQUE INDEX "index_oauth_access_tokens_on_refresh_token" ON "oauth_access_tokens" ("refresh_token");
CREATE INDEX "index_oauth_access_tokens_on_resource_owner_id" ON "oauth_access_tokens" ("resource_owner_id");
CREATE UNIQUE INDEX "index_oauth_access_tokens_on_token" ON "oauth_access_tokens" ("token");
CREATE TABLE IF NOT EXISTS "oauth_applications" ("id" SERIAL PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "uid" varchar NOT NULL, "secret" varchar NOT NULL, "redirect_uri" text NOT NULL, "scopes" varchar DEFAULT '' NOT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE UNIQUE INDEX "index_oauth_applications_on_uid" ON "oauth_applications" ("uid");
CREATE TABLE IF NOT EXISTS "phase_orders" ("id" SERIAL PRIMARY KEY NOT NULL, "sequence_data" varchar, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "user_id" integer, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_phase_orders_on_protocol_definition_id" ON "phase_orders" ("protocol_definition_id");
CREATE INDEX "index_phase_orders_on_study_definition_id" ON "phase_orders" ("study_definition_id");
CREATE INDEX "index_phase_orders_on_user_id" ON "phase_orders" ("user_id");
CREATE TABLE IF NOT EXISTS "protocol_definitions" ("id" SERIAL PRIMARY KEY NOT NULL, "name" varchar, "version" integer, "type" varchar, "summary" varchar, "description" varchar, "definition_data" varchar, "active" boolean DEFAULT 'f' NOT NULL, "study_definition_id" integer NOT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_protocol_definitions_on_study_definition_id" ON "protocol_definitions" ("study_definition_id");
CREATE TABLE IF NOT EXISTS "protocol_users" ("id" SERIAL PRIMARY KEY NOT NULL, "user_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "group_name" varchar, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_protocol_users_on_group_name" ON "protocol_users" ("group_name");
CREATE INDEX "index_protocol_users_on_protocol_definition_id" ON "protocol_users" ("protocol_definition_id");
CREATE INDEX "index_protocol_users_on_user_id" ON "protocol_users" ("user_id");
CREATE TABLE IF NOT EXISTS "stimuli" ("id" SERIAL PRIMARY KEY NOT NULL, "definition_data" varchar, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "phase_definition_id" integer NOT NULL, "trial_definition_id" integer NOT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_stimuli_on_phase_definition_id" ON "stimuli" ("phase_definition_id");
CREATE INDEX "index_stimuli_on_protocol_definition_id" ON "stimuli" ("protocol_definition_id");
CREATE INDEX "index_stimuli_on_study_definition_id" ON "stimuli" ("study_definition_id");
CREATE INDEX "index_stimuli_on_trial_definition_id" ON "stimuli" ("trial_definition_id");
CREATE TABLE IF NOT EXISTS "study_result_contexts" ("id" SERIAL PRIMARY KEY NOT NULL, "timestamp" timestamp, "context_type" text, "data" text, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE TABLE IF NOT EXISTS "study_result_data_points" ("id" SERIAL PRIMARY KEY NOT NULL, "stage_id" integer NOT NULL, "protocol_user_id" integer, "phase_definition_id" integer, "trial_definition_id" integer, "component_id" integer, "kind" varchar, "point_type" varchar, "value" varchar, "method" varchar, "timestamp" timestamp, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_study_result_data_points_on_component_id" ON "study_result_data_points" ("component_id");
CREATE INDEX "index_study_result_data_points_on_phase_definition_id" ON "study_result_data_points" ("phase_definition_id");
CREATE INDEX "index_study_result_data_points_on_protocol_user_id" ON "study_result_data_points" ("protocol_user_id");
CREATE INDEX "index_study_result_data_points_on_trial_definition_id" ON "study_result_data_points" ("trial_definition_id");
CREATE TABLE IF NOT EXISTS "study_result_experiments" ("id" SERIAL PRIMARY KEY NOT NULL, "study_result_id" integer NOT NULL, "protocol_user_id" integer NOT NULL, "current_stage_id" integer, "num_stages_completed" integer, "num_stages_remaining" integer, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "started_at" timestamp, "completed_at" timestamp, "custom_parameters" jsonb);
CREATE INDEX "index_study_result_experiments_on_protocol_user_id" ON "study_result_experiments" ("protocol_user_id");
CREATE TABLE IF NOT EXISTS "study_result_stages" ("id" SERIAL PRIMARY KEY NOT NULL, "experiment_id" integer NOT NULL, "protocol_user_id" integer NOT NULL, "phase_definition_id" integer NOT NULL, "last_completed_trial" integer, "current_trial" integer, "num_trials" integer, "context_id" integer, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "started_at" timestamp, "completed_at" timestamp);
CREATE INDEX "index_study_result_stages_on_phase_definition_id" ON "study_result_stages" ("phase_definition_id");
CREATE INDEX "index_study_result_stages_on_protocol_user_id" ON "study_result_stages" ("protocol_user_id");
CREATE TABLE IF NOT EXISTS "study_result_study_results" ("id" SERIAL PRIMARY KEY NOT NULL, "study_definition_id" integer, "user_id" integer, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "started_at" timestamp, "completed_at" timestamp);
CREATE INDEX "index_study_result_study_results_on_study_definition_id" ON "study_result_study_results" ("study_definition_id");
CREATE INDEX "index_study_result_study_results_on_user_id" ON "study_result_study_results" ("user_id");
CREATE TABLE IF NOT EXISTS "study_result_time_series" ("id" SERIAL PRIMARY KEY NOT NULL, "stage_id" integer, "study_definition_id" integer, "protocol_definition_id" integer, "phase_definition_id" integer, "component_id" integer, "file" varchar, "schema" varchar, "schema_metadata" varchar, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE INDEX "index_study_result_time_series_on_component_id" ON "study_result_time_series" ("component_id");
CREATE INDEX "index_study_result_time_series_on_phase_definition_id" ON "study_result_time_series" ("phase_definition_id");
CREATE INDEX "index_study_result_time_series_on_protocol_definition_id" ON "study_result_time_series" ("protocol_definition_id");
CREATE INDEX "index_study_result_time_series_on_study_definition_id" ON "study_result_time_series" ("study_definition_id");
CREATE TABLE IF NOT EXISTS "study_result_trial_results" ("id" SERIAL PRIMARY KEY NOT NULL, "experiment_id" integer NOT NULL, "protocol_user_id" integer NOT NULL, "phase_definition_id" integer NOT NULL, "trial_definition_id" integer NOT NULL, "session_name" varchar, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "started_at" timestamp, "completed_at" timestamp);
CREATE INDEX "index_study_result_trial_results_on_phase_definition_id" ON "study_result_trial_results" ("phase_definition_id");
CREATE INDEX "index_study_result_trial_results_on_protocol_user_id" ON "study_result_trial_results" ("protocol_user_id");
CREATE INDEX "index_study_result_trial_results_on_trial_definition_id" ON "study_result_trial_results" ("trial_definition_id");
CREATE TABLE IF NOT EXISTS "trial_definitions" ("id" SERIAL PRIMARY KEY NOT NULL, "definition_data" varchar, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "phase_definition_id" integer NOT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "name" varchar, "description" varchar);
CREATE INDEX "index_trial_definitions_on_phase_definition_id" ON "trial_definitions" ("phase_definition_id");
CREATE INDEX "index_trial_definitions_on_protocol_definition_id" ON "trial_definitions" ("protocol_definition_id");
CREATE INDEX "index_trial_definitions_on_study_definition_id" ON "trial_definitions" ("study_definition_id");
CREATE TABLE IF NOT EXISTS "users" ("id" SERIAL PRIMARY KEY NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" timestamp, "remember_created_at" timestamp, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" timestamp, "last_sign_in_at" timestamp, "current_sign_in_ip" varchar, "last_sign_in_ip" varchar, "confirmation_token" varchar, "confirmed_at" timestamp, "confirmation_sent_at" timestamp, "unconfirmed_email" varchar, "anonymous" boolean, "role" varchar, "username" varchar, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE TABLE IF NOT EXISTS "phase_definitions" ("id" SERIAL PRIMARY KEY, "definition_data" varchar DEFAULT NULL, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "trial_ordering" varchar);
CREATE INDEX "index_phase_definitions_on_protocol_definition_id" ON "phase_definitions" ("protocol_definition_id");
CREATE INDEX "index_phase_definitions_on_study_definition_id" ON "phase_definitions" ("study_definition_id");
CREATE TABLE IF NOT EXISTS "trial_orders" ("id" SERIAL PRIMARY KEY, "sequence_data" varchar DEFAULT NULL, "study_definition_id" integer NOT NULL, "protocol_definition_id" integer NOT NULL, "phase_definition_id" integer NOT NULL, "user_id" integer DEFAULT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL);
CREATE TABLE IF NOT EXISTS "trial_order_selection_mappings" ("id" SERIAL PRIMARY KEY NOT NULL, "trial_order_id" integer, "user_id" integer, "phase_definition_id" integer, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, CONSTRAINT "fk_rails_8c4c7d984f"
FOREIGN KEY ("trial_order_id")
  REFERENCES "trial_orders" ("id")
, CONSTRAINT "fk_rails_c5de20bf65"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_dd6e57ae7e"
FOREIGN KEY ("phase_definition_id")
  REFERENCES "phase_definitions" ("id")
);
CREATE INDEX "index_trial_order_selection_mappings_on_trial_order_id" ON "trial_order_selection_mappings" ("trial_order_id");
CREATE INDEX "index_trial_order_selection_mappings_on_user_id" ON "trial_order_selection_mappings" ("user_id");
CREATE INDEX "index_trial_order_selection_mappings_on_phase_definition_id" ON "trial_order_selection_mappings" ("phase_definition_id");
CREATE INDEX "index_trial_orders_on_phase_definition_id" ON "trial_orders" ("phase_definition_id");
CREATE INDEX "index_trial_orders_on_protocol_definition_id" ON "trial_orders" ("protocol_definition_id");
CREATE INDEX "index_trial_orders_on_study_definition_id" ON "trial_orders" ("study_definition_id");
CREATE INDEX "index_trial_orders_on_user_id" ON "trial_orders" ("user_id");
CREATE TABLE IF NOT EXISTS "study_definitions" ("id" SERIAL PRIMARY KEY, "title" varchar DEFAULT NULL, "description" varchar DEFAULT NULL, "principal_investigator_user_id" integer NOT NULL, "version" integer DEFAULT NULL, "data" text DEFAULT NULL, "lock_question" integer DEFAULT NULL, "enable_previous" integer DEFAULT NULL, "no_of_trials" integer DEFAULT NULL, "trials_completed" integer DEFAULT NULL, "footer_label" text DEFAULT NULL, "redirect_close_on_url" varchar DEFAULT NULL, "created_at" timestamp NOT NULL, "updated_at" timestamp NOT NULL, "AllowAnonymousUsers" boolean DEFAULT NULL, "ShowInStudyList" boolean DEFAULT NULL, "allow_anonymous_users" boolean, "show_in_study_list" boolean, "max_anonymous_users" integer);
CREATE INDEX "index_study_definitions_on_principal_investigator_user_id" ON "study_definitions" ("principal_investigator_user_id");
CREATE INDEX "index_chaos_sessions_on_user_id" ON "chaos_sessions" ("user_id");
CREATE INDEX "index_chaos_sessions_on_study_definition_id" ON "chaos_sessions" ("study_definition_id");
CREATE INDEX "index_chaos_sessions_on_protocol_definition_id" ON "chaos_sessions" ("protocol_definition_id");
CREATE INDEX "index_chaos_sessions_on_phase_definition_id" ON "chaos_sessions" ("phase_definition_id");
CREATE INDEX "index_chaos_sessions_on_trial_definition_id" ON "chaos_sessions" ("trial_definition_id");
CREATE INDEX "index_chaos_sessions_on_protocol_user_id" ON "chaos_sessions" ("protocol_user_id");
CREATE INDEX "index_chaos_sessions_on_study_result_id" ON "chaos_sessions" ("study_result_id");
CREATE INDEX "index_chaos_sessions_on_experiment_id" ON "chaos_sessions" ("experiment_id");
CREATE INDEX "index_chaos_sessions_on_stage_id" ON "chaos_sessions" ("stage_id");
CREATE INDEX "index_chaos_sessions_on_trial_result_id" ON "chaos_sessions" ("trial_result_id");
CREATE INDEX "index_oauth_access_grants_on_resource_owner_id" ON "oauth_access_grants" ("resource_owner_id");
CREATE INDEX "index_study_result_data_points_on_stage_id" ON "study_result_data_points" ("stage_id");
CREATE INDEX "index_study_result_experiments_on_study_result_id" ON "study_result_experiments" ("study_result_id");
CREATE INDEX "index_study_result_experiments_on_current_stage_id" ON "study_result_experiments" ("current_stage_id");
CREATE INDEX "index_study_result_stages_on_experiment_id" ON "study_result_stages" ("experiment_id");
CREATE INDEX "index_study_result_stages_on_context_id" ON "study_result_stages" ("context_id");
CREATE INDEX "index_study_result_time_series_on_stage_id" ON "study_result_time_series" ("stage_id");
CREATE INDEX "index_study_result_trial_results_on_experiment_id" ON "study_result_trial_results" ("experiment_id");
CREATE INDEX "index_study_definitions_on_allow_anonymous_users" ON "study_definitions" ("allow_anonymous_users");
CREATE INDEX "index_study_definitions_on_show_in_study_list" ON "study_definitions" ("show_in_study_list");
INSERT INTO "schema_migrations" (version) VALUES
('20170829210919'),
('20181207090515'),
('20181207091722'),
('20181210111808'),
('20181216113752'),
('20181218035443'),
('20190118161909'),
('20190120052807');


