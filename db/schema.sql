
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


COMMENT ON DATABASE postgres IS 'default administrative connection database';



CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;



COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE admins (
    openid text,
    invite_code character varying(4)
);



CREATE TABLE schema_migrations (
    version character varying(28)
);



CREATE TABLE show (
    id integer NOT NULL,
    bill text NOT NULL,
    venue text NOT NULL,
    display_notes text,
    provenance text,
    "time" time without time zone,
    date date NOT NULL
);



CREATE SEQUENCE show_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE show_id_seq OWNED BY show.id;



ALTER TABLE ONLY show ALTER COLUMN id SET DEFAULT nextval('show_id_seq'::regclass);



ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_invite_code_key UNIQUE (invite_code);



ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_openid_key UNIQUE (openid);



ALTER TABLE ONLY show
    ADD CONSTRAINT show_pkey PRIMARY KEY (id);


