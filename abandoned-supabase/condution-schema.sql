--
-- PostgreSQL database dump
--

-- Dumped from database version 12.6 (Ubuntu 12.6-1.pgdg18.04+1)
-- Dumped by pg_dump version 13.3

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

DROP EVENT TRIGGER api_restart;
DROP PUBLICATION supabase_realtime;
DROP POLICY "Allow owners to update owner's data" ON public.profiles;
DROP POLICY "Allow owners to update data" ON public.tasks;
DROP POLICY "Allow owners to update data" ON public.tags;
DROP POLICY "Allow owners to update data" ON public.projects;
DROP POLICY "Allow owners to see owner's data" ON public.profiles;
DROP POLICY "Allow owners to grep their data" ON public.tasks;
DROP POLICY "Allow owners to grep their data" ON public.tags;
DROP POLICY "Allow owners to grep their data" ON public.projects;
DROP POLICY "Allow owners to delete owner's data" ON public.profiles;
DROP POLICY "Allow owners to delete data" ON public.tasks;
DROP POLICY "Allow owners to delete data" ON public.tags;
DROP POLICY "Allow owners to delete data" ON public.projects;
DROP POLICY "Allow authenticated owners to insert data" ON public.profiles;
DROP POLICY "Allow authenticated folks to insert" ON public.tasks;
DROP POLICY "Allow authenticated folks to insert" ON public.tags;
DROP POLICY "Allow authenticated folks to insert" ON public.projects;
ALTER TABLE ONLY public.wtasks DROP CONSTRAINT wtasks_owner_fkey;
ALTER TABLE ONLY public.wtags DROP CONSTRAINT wtags_owner_fkey;
ALTER TABLE ONLY public.wprojects DROP CONSTRAINT wprojects_owner_fkey;
ALTER TABLE ONLY public.tasks DROP CONSTRAINT tasks_owner_fkey;
ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_owner_fkey;
ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_owner_fkey;
DROP INDEX auth.users_instance_id_idx;
DROP INDEX auth.users_instance_id_email_idx;
DROP INDEX auth.refresh_tokens_token_idx;
DROP INDEX auth.refresh_tokens_instance_id_user_id_idx;
DROP INDEX auth.refresh_tokens_instance_id_idx;
DROP INDEX auth.audit_logs_instance_id_idx;
ALTER TABLE ONLY public.wtasks DROP CONSTRAINT wtasks_pkey;
ALTER TABLE ONLY public.wtags DROP CONSTRAINT wtags_pkey;
ALTER TABLE ONLY public.wprojects DROP CONSTRAINT wprojects_pkey;
ALTER TABLE ONLY public.workspaces DROP CONSTRAINT workspaces_pkey;
ALTER TABLE ONLY public.tasks DROP CONSTRAINT tasks_pkey;
ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_pkey;
ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_pkey;
ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_pkey;
ALTER TABLE ONLY auth.users DROP CONSTRAINT users_pkey;
ALTER TABLE ONLY auth.users DROP CONSTRAINT users_email_key;
ALTER TABLE ONLY auth.schema_migrations DROP CONSTRAINT schema_migrations_pkey;
ALTER TABLE ONLY auth.refresh_tokens DROP CONSTRAINT refresh_tokens_pkey;
ALTER TABLE ONLY auth.instances DROP CONSTRAINT instances_pkey;
ALTER TABLE ONLY auth.audit_log_entries DROP CONSTRAINT audit_log_entries_pkey;
ALTER TABLE auth.refresh_tokens ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.wtasks;
DROP TABLE public.wtags;
DROP TABLE public.wprojects;
DROP TABLE public.workspaces;
DROP TABLE public.tasks;
DROP TABLE public.tags;
DROP TABLE public.projects;
DROP TABLE public.profiles;
DROP TABLE auth.users;
DROP TABLE auth.schema_migrations;
DROP SEQUENCE auth.refresh_tokens_id_seq;
DROP TABLE auth.refresh_tokens;
DROP TABLE auth.instances;
DROP TABLE auth.audit_log_entries;
DROP FUNCTION pgbouncer.get_auth(p_usename text);
DROP FUNCTION extensions.notify_api_restart();
DROP FUNCTION auth.uid();
DROP FUNCTION auth.role();
DROP EXTENSION "uuid-ossp";
DROP EXTENSION pgjwt;
DROP EXTENSION pgcrypto;
DROP SCHEMA pgbouncer;
DROP SCHEMA extensions;
DROP SCHEMA auth;
--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select nullif(current_setting('request.jwt.claim.role', true), '')::text;
$$;


ALTER FUNCTION auth.role() OWNER TO postgres;

--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;


ALTER FUNCTION auth.uid() OWNER TO postgres;

--
-- Name: notify_api_restart(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.notify_api_restart() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NOTIFY ddl_command_end;
END;
$$;


ALTER FUNCTION extensions.notify_api_restart() OWNER TO postgres;

--
-- Name: FUNCTION notify_api_restart(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.notify_api_restart() IS 'Sends a notification to the API to restart. If your database schema has changed, this is required so that Supabase can rebuild the relationships.';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;
 
    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone
);


ALTER TABLE auth.audit_log_entries OWNER TO postgres;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO postgres;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.refresh_tokens OWNER TO postgres;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.refresh_tokens_id_seq OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: postgres
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO postgres;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    payload json DEFAULT '{}'::json
);


ALTER TABLE public.profiles OWNER TO supabase_admin;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.profiles IS 'User chains and workspaces profile';


--
-- Name: projects; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    owner uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.projects OWNER TO supabase_admin;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    owner uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.tags OWNER TO supabase_admin;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.tasks (
    id uuid NOT NULL,
    owner uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.tasks OWNER TO supabase_admin;

--
-- Name: TABLE tasks; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.tasks IS 'Get ''em tasks';


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.workspaces OWNER TO supabase_admin;

--
-- Name: TABLE workspaces; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.workspaces IS 'Workspace profiles, like name and editors.';


--
-- Name: wprojects; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.wprojects (
    id uuid NOT NULL,
    owner uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.wprojects OWNER TO supabase_admin;

--
-- Name: wtags; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.wtags (
    id uuid NOT NULL,
    owner uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.wtags OWNER TO supabase_admin;

--
-- Name: TABLE wtags; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.wtags IS 'workspace tags';


--
-- Name: wtasks; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.wtasks (
    id uuid NOT NULL,
    owner uuid NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL
);


ALTER TABLE public.wtasks OWNER TO supabase_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: wprojects wprojects_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.wprojects
    ADD CONSTRAINT wprojects_pkey PRIMARY KEY (id);


--
-- Name: wtags wtags_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.wtags
    ADD CONSTRAINT wtags_pkey PRIMARY KEY (id);


--
-- Name: wtasks wtasks_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.wtasks
    ADD CONSTRAINT wtasks_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_token_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, email);


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: projects projects_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_owner_fkey FOREIGN KEY (owner) REFERENCES public.profiles(id);


--
-- Name: tags tags_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_owner_fkey FOREIGN KEY (owner) REFERENCES public.profiles(id);


--
-- Name: tasks tasks_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_owner_fkey FOREIGN KEY (owner) REFERENCES public.profiles(id);


--
-- Name: wprojects wprojects_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.wprojects
    ADD CONSTRAINT wprojects_owner_fkey FOREIGN KEY (owner) REFERENCES public.workspaces(id);


--
-- Name: wtags wtags_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.wtags
    ADD CONSTRAINT wtags_owner_fkey FOREIGN KEY (owner) REFERENCES public.workspaces(id);


--
-- Name: wtasks wtasks_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.wtasks
    ADD CONSTRAINT wtasks_owner_fkey FOREIGN KEY (owner) REFERENCES public.workspaces(id);


--
-- Name: projects Allow authenticated folks to insert; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow authenticated folks to insert" ON public.projects FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: tags Allow authenticated folks to insert; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow authenticated folks to insert" ON public.tags FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: tasks Allow authenticated folks to insert; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow authenticated folks to insert" ON public.tasks FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: profiles Allow authenticated owners to insert data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow authenticated owners to insert data" ON public.profiles FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: projects Allow owners to delete data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to delete data" ON public.projects FOR DELETE USING ((auth.uid() = owner));


--
-- Name: tags Allow owners to delete data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to delete data" ON public.tags FOR DELETE USING ((auth.uid() = owner));


--
-- Name: tasks Allow owners to delete data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to delete data" ON public.tasks FOR DELETE USING ((auth.uid() = owner));


--
-- Name: profiles Allow owners to delete owner's data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to delete owner's data" ON public.profiles FOR DELETE USING ((auth.uid() = id));


--
-- Name: projects Allow owners to grep their data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to grep their data" ON public.projects FOR SELECT USING ((auth.uid() = owner));


--
-- Name: tags Allow owners to grep their data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to grep their data" ON public.tags FOR SELECT USING ((auth.uid() = owner));


--
-- Name: tasks Allow owners to grep their data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to grep their data" ON public.tasks FOR SELECT USING ((auth.uid() = owner));


--
-- Name: profiles Allow owners to see owner's data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to see owner's data" ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: projects Allow owners to update data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to update data" ON public.projects FOR UPDATE USING ((auth.uid() = owner));


--
-- Name: tags Allow owners to update data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to update data" ON public.tags FOR UPDATE USING ((auth.uid() = owner));


--
-- Name: tasks Allow owners to update data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to update data" ON public.tasks FOR UPDATE USING ((auth.uid() = owner));


--
-- Name: profiles Allow owners to update owner's data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow owners to update owner's data" ON public.profiles FOR UPDATE USING ((auth.uid() = id));


--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON TABLE auth.audit_log_entries TO supabase_auth_admin;
GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON TABLE auth.instances TO supabase_auth_admin;
GRANT ALL ON TABLE auth.instances TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON TABLE auth.refresh_tokens TO supabase_auth_admin;
GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO supabase_auth_admin;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON TABLE auth.schema_migrations TO supabase_auth_admin;
GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: postgres
--

GRANT ALL ON TABLE auth.users TO supabase_auth_admin;
GRANT ALL ON TABLE auth.users TO dashboard_user;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.profiles TO postgres;
GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE projects; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.projects TO postgres;
GRANT ALL ON TABLE public.projects TO anon;
GRANT ALL ON TABLE public.projects TO authenticated;
GRANT ALL ON TABLE public.projects TO service_role;


--
-- Name: TABLE tags; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.tags TO postgres;
GRANT ALL ON TABLE public.tags TO anon;
GRANT ALL ON TABLE public.tags TO authenticated;
GRANT ALL ON TABLE public.tags TO service_role;


--
-- Name: TABLE tasks; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.tasks TO postgres;
GRANT ALL ON TABLE public.tasks TO anon;
GRANT ALL ON TABLE public.tasks TO authenticated;
GRANT ALL ON TABLE public.tasks TO service_role;


--
-- Name: TABLE workspaces; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.workspaces TO postgres;
GRANT ALL ON TABLE public.workspaces TO anon;
GRANT ALL ON TABLE public.workspaces TO authenticated;
GRANT ALL ON TABLE public.workspaces TO service_role;


--
-- Name: TABLE wprojects; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.wprojects TO postgres;
GRANT ALL ON TABLE public.wprojects TO anon;
GRANT ALL ON TABLE public.wprojects TO authenticated;
GRANT ALL ON TABLE public.wprojects TO service_role;


--
-- Name: TABLE wtags; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.wtags TO postgres;
GRANT ALL ON TABLE public.wtags TO anon;
GRANT ALL ON TABLE public.wtags TO authenticated;
GRANT ALL ON TABLE public.wtags TO service_role;


--
-- Name: TABLE wtasks; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.wtasks TO postgres;
GRANT ALL ON TABLE public.wtasks TO anon;
GRANT ALL ON TABLE public.wtasks TO authenticated;
GRANT ALL ON TABLE public.wtasks TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON SEQUENCES  FROM supabase_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON FUNCTIONS  FROM supabase_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES  FROM supabase_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: api_restart; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER api_restart ON ddl_command_end
   EXECUTE FUNCTION extensions.notify_api_restart();


ALTER EVENT TRIGGER api_restart OWNER TO postgres;

--
-- PostgreSQL database dump complete
--
