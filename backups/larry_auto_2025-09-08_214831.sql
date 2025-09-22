--
-- PostgreSQL database dump
--

\restrict gxRRrGZdsY1xT14jqt0rKoiu7yDQQMne6Q1bBbtqvcwojHXMy33l0RaQVY4eDe4

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
9efd9247-2759-4a69-ad63-7b09c6c762f5	ff520332-6b7f-45bd-a749-ff31b44dd180	tennis originated in the 12th century in france where it was played with the palm of the hand rackets came into use during the 16th century	AI Generated	\N	t	general	2025-09-08 21:42:30.337
283fd33d-ec77-4b1c-b20c-10d5a87bd0aa	ff520332-6b7f-45bd-a749-ff31b44dd180	the fastest serve ever recorded was hit by sam groth at 1637 mph 2634 kmh during a match in 2012	AI Generated	\N	t	general	2025-09-08 21:42:30.337
cd37f8e8-3bd3-4585-8937-d9323d27b074	ff520332-6b7f-45bd-a749-ff31b44dd180	tennis was first included in the olympic games in 1896 but was dropped after the 1924 games it returned as a full-medal sport in 1988	AI Generated	\N	t	general	2025-09-08 21:42:30.337
0d8e453a-a186-4fe0-bb12-606555646ff3	ff520332-6b7f-45bd-a749-ff31b44dd180	the longest match in professional tennis history took place at wimbledon in 2010 when john isner defeated nicolas mahut in a match that lasted 11 hours and 5 minutes over three days	AI Generated	\N	t	history	2025-09-08 21:42:30.337
21c1de35-fef9-411f-81d3-1be2563d4b9c	ff520332-6b7f-45bd-a749-ff31b44dd180	the term love in tennis meaning zero is thought to come from the french word for egg loeuf because an egg looks like a zero	AI Generated	\N	t	general	2025-09-08 21:42:30.337
9afdbd67-18aa-48f2-953c-d0ea5bf2a006	ff520332-6b7f-45bd-a749-ff31b44dd180	the first tennis balls were made of wool or hair wrapped in leather modern tennis balls are made of hollow rubber with a felt coating	AI Generated	\N	t	general	2025-09-08 21:42:30.337
3f1ad00a-ed53-488f-bf1d-b06cd843916a	ff520332-6b7f-45bd-a749-ff31b44dd180	wimbledon one of the four grand slam events is the oldest tennis tournament in the world it began in 1877	AI Generated	\N	t	general	2025-09-08 21:42:30.337
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, "topicId", "canonicalSetId", term, definition, example, source, "sourceUrl", verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "createdAt") FROM stdin;
b21780b7-9ba0-437d-a731-2d669f48aaeb	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	ace	An ace is a playing card, die or domino with a single pip. In the standard French deck, an ace has a single suit symbol located in the middle of the card, sometimes large and decorated, especially in ...	He scored an ace on his first serve.	Wikipedia	https://en.wikipedia.org/wiki/Ace	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
5c98e988-1cfa-4551-8dc5-f34549dc1e2e	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	baseline	A baseline is a line that is a base for measurement or for construction....	The player hit the ball just inside the baseline.	Wikipedia	https://en.wikipedia.org/wiki/Baseline	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
2c71d355-c9af-4b3f-9c26-8e17a902b896	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	deuce	Deuce, Deuces, or The Deuce may refer to:...	The game went to deuce four times before he finally won.	Wikipedia	https://en.wikipedia.org/wiki/Deuce	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
ceb66675-4906-427a-a27d-94e80e6bb4c5	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	double fault	On the x86 architecture, a double fault exception occurs if the processor encounters a problem while trying to service a pending interrupt or exception. An example situation when a double fault would ...	Her double fault cost her the game.	Wikipedia	https://en.wikipedia.org/wiki/Double_fault	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
bcd10a1d-7e8f-475c-84f2-3d4d16fcaeca	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	lob	Lob may refer to:...	He hit a perfect lob that landed just inside the baseline.	Wikipedia	https://en.wikipedia.org/wiki/Lob	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
b79483a6-2ce6-4a45-8a27-afd9c3ad5865	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	match point	Match point may refer to:Match point (tennis), won if the player in the lead scores\nMatchpoint scoring, in duplicate bridge\nMatch Point, a 2005 film directed by Woody Allen\nMatchpoint , a 1990 British...	He served an ace on match point to win the tournament.	Wikipedia	https://en.wikipedia.org/wiki/Match_point	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
1fd1bccb-24cd-4e4d-b73d-db2727eb206e	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	rally	Rally or rallye may refer to:...	They had a long rally before he finally hit the ball out.	Wikipedia	https://en.wikipedia.org/wiki/Rally	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
7cff1b6e-044c-45e5-b372-89f806b3b9d5	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	serve	Serve or SERVE may refer to:...	He has one of the fastest serves in the game.	Wikipedia	https://en.wikipedia.org/wiki/Serve	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
1c573840-f7b4-4c56-a935-9e6b6ed1fe96	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	slice	Slice may refer to:Cutting...	He used a slice to make the ball skid and stay low.	Wikipedia	https://en.wikipedia.org/wiki/Slice	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
ac6ee759-bc58-4f74-9a26-17bd85cf0e4d	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	volley	Volley or Volly may refer to:...	She hit a winning volley at the net.	Wikipedia	https://en.wikipedia.org/wiki/Volley	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
f35cdfa1-c8a1-4579-969a-c760d106db26	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	break point	Tennis is a racket sport that is played either individually against a single opponent (singles) or between two teams of two players each (doubles). Each player uses a tennis racket strung with a cord ...	He capitalized on his opponent's double fault and won the break point.	Wikipedia	https://en.wikipedia.org/wiki/Tennis	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
a5eccc4b-a55a-421e-9745-f383122dc383	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	grand slam	Grand Slam or Grand slam may refer to:...	Winning a Grand Slam is the dream of every professional tennis player.	Wikipedia	https://en.wikipedia.org/wiki/Grand_Slam	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
161f8b02-dc90-4461-932d-dc141b40ee29	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	let	Let or LET may refer to:...	The serve was a let, so he had another chance to serve.	Wikipedia	https://en.wikipedia.org/wiki/Let	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
8401ffb4-176d-412e-8f87-c947e66a3cc2	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	tiebreak	In games and sport, a tiebreaker or tiebreak is any method used to determine a winner or to rank participants when there is a tie - meaning two or more parties have achieved a same score or result. A ...	They had to go into a tiebreak to decide the winner of the set.	Wikipedia	https://en.wikipedia.org/wiki/Tiebreaker	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
18f947cf-8b83-4016-b5ba-9e171a84113c	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	unforced error	\nThis page is a glossary of tennis terminology....	His unforced errors cost him the match.	Wikipedia	https://en.wikipedia.org/wiki/Glossary_of_tennis_terms	f	t	0.5	general	beginner	2025-09-08 21:42:30.33
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

\unrestrict gxRRrGZdsY1xT14jqt0rKoiu7yDQQMne6Q1bBbtqvcwojHXMy33l0RaQVY4eDe4

