
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


CREATE TABLE schema_migrations (
    version character varying(28)
);



CREATE TABLE show (
    id integer NOT NULL,
    bands text[] NOT NULL,
    venue json NOT NULL,
    notes text,
    "time" timestamp with time zone NOT NULL
);



CREATE SEQUENCE show_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE show_id_seq OWNED BY show.id;



ALTER TABLE ONLY show ALTER COLUMN id SET DEFAULT nextval('show_id_seq'::regclass);



ALTER TABLE ONLY show
    ADD CONSTRAINT show_pkey PRIMARY KEY (id);


