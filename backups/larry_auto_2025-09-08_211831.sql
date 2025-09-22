--
-- PostgreSQL database dump
--

\restrict FBrUyG8DnBONdev4CCn8S0D5OJMbfNdTkatOuGHLg2NWcAcvP0taTIvgXDeUbK4

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CanonicalSet; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CanonicalSet" (
    id text NOT NULL
);


--
-- Name: Fact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Fact" (
    id text NOT NULL,
    "topicId" text NOT NULL,
    fact text NOT NULL,
    source text NOT NULL,
    "sourceUrl" text,
    "gptGenerated" boolean NOT NULL,
    category text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Term; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Term" (
    id text NOT NULL,
    "topicId" text NOT NULL,
    "canonicalSetId" text,
    term text NOT NULL,
    definition text NOT NULL,
    example text NOT NULL,
    source text NOT NULL,
    "sourceUrl" text,
    verified boolean NOT NULL,
    "gptGenerated" boolean NOT NULL,
    "confidenceScore" double precision NOT NULL,
    category text NOT NULL,
    "complexityLevel" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Topic" (
    id text NOT NULL,
    name text NOT NULL,
    "canonicalSetId" text
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    subscription text DEFAULT 'free'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: UserQuota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserQuota" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "currentUsage" integer DEFAULT 0 NOT NULL,
    "periodStart" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastReset" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: UserTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserTopic" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "topicId" text NOT NULL,
    weight integer NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Data for Name: CanonicalSet; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CanonicalSet" (id) FROM stdin;
e8871648-d165-4df0-95e7-1c904f2e80e9
\.


--
-- Data for Name: Fact; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Fact" (id, "topicId", fact, source, "sourceUrl", "gptGenerated", category, "createdAt") FROM stdin;
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, "topicId", "canonicalSetId", term, definition, example, source, "sourceUrl", verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "createdAt") FROM stdin;
\.


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Topic" (id, name, "canonicalSetId") FROM stdin;
ff520332-6b7f-45bd-a749-ff31b44dd180	tennis	e8871648-d165-4df0-95e7-1c904f2e80e9
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, subscription, "createdAt") FROM stdin;
ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	test@larry.com	free	2025-09-05 17:29:34.475
\.


--
-- Data for Name: UserQuota; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserQuota" (id, "userId", "currentUsage", "periodStart", "lastReset", "createdAt", "updatedAt") FROM stdin;
78d4c499-5e0e-4e4b-a0e7-f02c1def781e	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	1	2025-09-05 17:29:46.222	2025-09-05 17:29:46.222	2025-09-05 17:29:46.222	2025-09-05 17:29:46.231
\.


--
-- Data for Name: UserTopic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserTopic" (id, "userId", "topicId", weight) FROM stdin;
a24de36d-174f-4c73-863f-06ac41498a0f	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	ff520332-6b7f-45bd-a749-ff31b44dd180	100
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
85860666-4a80-42fb-865a-00a4f037a45a	8e2ff6e44db6a6e77c45cbfece6d9e32087c00cc7624af710a08cc7b519a56dc	2025-09-05 17:27:50.87221+00	20250901193144_super_api_migration	\N	\N	2025-09-05 17:27:50.850097+00	1
4f9e4090-0128-4728-8706-d3f7221e8cde	e22239f6ca919da58910c9f2609af0a84750c6cabeae347f95f6cf1f7ea40e2c	2025-09-05 17:27:50.88302+00	20250903062759_quota_add_migration	\N	\N	2025-09-05 17:27:50.874065+00	1
8429832f-a51a-4ac2-b7fa-9096a574889f	50c52370a6841cd655c485dcb07ca9356cad7bb39028e75ca1c3a0213526d160	2025-09-05 17:27:53.383175+00	20250905172753_add_unique_constraints	\N	\N	2025-09-05 17:27:53.374742+00	1
\.


--
-- Name: CanonicalSet CanonicalSet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CanonicalSet"
    ADD CONSTRAINT "CanonicalSet_pkey" PRIMARY KEY (id);


--
-- Name: Fact Fact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_pkey" PRIMARY KEY (id);


--
-- Name: Term Term_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_pkey" PRIMARY KEY (id);


--
-- Name: Topic Topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_pkey" PRIMARY KEY (id);


--
-- Name: UserQuota UserQuota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserQuota"
    ADD CONSTRAINT "UserQuota_pkey" PRIMARY KEY (id);


--
-- Name: UserTopic UserTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTopic"
    ADD CONSTRAINT "UserTopic_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Fact_topicId_fact_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Fact_topicId_fact_key" ON public."Fact" USING btree ("topicId", fact);


--
-- Name: Term_topicId_term_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Term_topicId_term_key" ON public."Term" USING btree ("topicId", term);


--
-- Name: UserQuota_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserQuota_userId_idx" ON public."UserQuota" USING btree ("userId");


--
-- Name: UserQuota_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserQuota_userId_key" ON public."UserQuota" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Fact Fact_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Term Term_canonicalSetId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_canonicalSetId_fkey" FOREIGN KEY ("canonicalSetId") REFERENCES public."CanonicalSet"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Term Term_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Topic Topic_canonicalSetId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_canonicalSetId_fkey" FOREIGN KEY ("canonicalSetId") REFERENCES public."CanonicalSet"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserQuota UserQuota_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserQuota"
    ADD CONSTRAINT "UserQuota_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserTopic UserTopic_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTopic"
    ADD CONSTRAINT "UserTopic_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserTopic UserTopic_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTopic"
    ADD CONSTRAINT "UserTopic_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict FBrUyG8DnBONdev4CCn8S0D5OJMbfNdTkatOuGHLg2NWcAcvP0taTIvgXDeUbK4

