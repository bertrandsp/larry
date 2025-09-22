--
-- PostgreSQL database dump
--

\restrict RAbzb3knelfs51Og7DB7sHbZQD6GWc0fwzjEgqyUrx7OJxF9hYcHJkrCB9atyTC

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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "moderationNote" text,
    "moderationStatus" text DEFAULT 'pending'::text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "updatedByAdmin" boolean DEFAULT false NOT NULL
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "moderationNote" text,
    "moderationStatus" text DEFAULT 'pending'::text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "updatedByAdmin" boolean DEFAULT false NOT NULL
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
59952848-6ca4-41fb-a59a-e05228cf9f06
6f344c61-c746-439c-8697-542466270031
0e5bd29c-e049-4dce-9800-d094ae95b657
\.


--
-- Data for Name: Fact; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Fact" (id, "topicId", fact, source, "sourceUrl", "gptGenerated", category, "createdAt", "moderationNote", "moderationStatus", "updatedAt", "updatedByAdmin") FROM stdin;
9efd9247-2759-4a69-ad63-7b09c6c762f5	ff520332-6b7f-45bd-a749-ff31b44dd180	tennis originated in the 12th century in france where it was played with the palm of the hand rackets came into use during the 16th century	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
283fd33d-ec77-4b1c-b20c-10d5a87bd0aa	ff520332-6b7f-45bd-a749-ff31b44dd180	the fastest serve ever recorded was hit by sam groth at 1637 mph 2634 kmh during a match in 2012	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
cd37f8e8-3bd3-4585-8937-d9323d27b074	ff520332-6b7f-45bd-a749-ff31b44dd180	tennis was first included in the olympic games in 1896 but was dropped after the 1924 games it returned as a full-medal sport in 1988	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
0d8e453a-a186-4fe0-bb12-606555646ff3	ff520332-6b7f-45bd-a749-ff31b44dd180	the longest match in professional tennis history took place at wimbledon in 2010 when john isner defeated nicolas mahut in a match that lasted 11 hours and 5 minutes over three days	AI Generated	\N	t	history	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
21c1de35-fef9-411f-81d3-1be2563d4b9c	ff520332-6b7f-45bd-a749-ff31b44dd180	the term love in tennis meaning zero is thought to come from the french word for egg loeuf because an egg looks like a zero	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
9afdbd67-18aa-48f2-953c-d0ea5bf2a006	ff520332-6b7f-45bd-a749-ff31b44dd180	the first tennis balls were made of wool or hair wrapped in leather modern tennis balls are made of hollow rubber with a felt coating	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
3f1ad00a-ed53-488f-bf1d-b06cd843916a	ff520332-6b7f-45bd-a749-ff31b44dd180	wimbledon one of the four grand slam events is the oldest tennis tournament in the world it began in 1877	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
21b1b6e8-e1d7-4f52-9b17-cea3b987168d	535e5d75-e346-4f2b-9522-095f7b452646	anime represents about 60 of the worlds animated television shows	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
58e8284d-33f7-4664-a481-a086db14f958	535e5d75-e346-4f2b-9522-095f7b452646	the first known anime was released in 1917 nearly a century ago	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
a35b9813-8e0d-48ef-bbfb-650cb0a575a0	535e5d75-e346-4f2b-9522-095f7b452646	the longest running anime series is sazae-san with over 7500 episodes	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
02035310-d96e-46b5-85b9-3eb97eeed8fc	535e5d75-e346-4f2b-9522-095f7b452646	the highest-grossing anime film of all time is your name released in 2016	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
f9f54a80-4545-42ee-b632-a656b24c14c6	535e5d75-e346-4f2b-9522-095f7b452646	anime industry revenue exceeded 20 billion usd in 2019	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
ca8f28bf-8738-4731-809f-20610648d409	535e5d75-e346-4f2b-9522-095f7b452646	anime is not just popular in japan it has a vast international audience	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
7567145a-ef34-4e25-8524-7a3cba192572	535e5d75-e346-4f2b-9522-095f7b452646	in japan more paper is used to print manga than toilet paper	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
4850fc21-def7-44c0-aaad-f8ebb5b7e6c1	535e5d75-e346-4f2b-9522-095f7b452646	anime is a significant part of japanese media culture and is a major export of japan influencing global pop culture in areas such as animation and graphic design	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
aa3ccd43-e16d-468b-a48a-5f60a5ed2f95	535e5d75-e346-4f2b-9522-095f7b452646	the longest running anime series is sazae-san which has aired over 7500 episodes since 1969	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
883b5d3e-ad5b-46f4-90a9-176836f750d5	535e5d75-e346-4f2b-9522-095f7b452646	hayao miyazaki a renowned anime director and co-founder of studio ghibli has won numerous awards for his work including an oscar for spirited away in 2003	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
13711158-517a-4616-b601-26afc82d4a1c	535e5d75-e346-4f2b-9522-095f7b452646	anime covers a wide range of genres from action and adventure to drama horror romance and science fiction catering to diverse audiences	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
cd0c8c91-ed54-42c4-916a-e8d173bca6ee	535e5d75-e346-4f2b-9522-095f7b452646	anime series often feature theme songs performed by popular japanese music artists and these songs can become major hits on their own	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
aa4a2178-61dd-4d03-84cb-c2058ba27ab4	535e5d75-e346-4f2b-9522-095f7b452646	anime and manga often explore complex themes and social issues and their storytelling can be as sophisticated as any literary work	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
b3707cd1-7c82-46b1-b05a-7fdffc1df403	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were expected to live by a strict code of ethics called bushido or the way of the warrior which emphasized honor loyalty and bravery	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
86e9c065-8a2e-48cc-93c6-7aae0a028dcc	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurai class made up only about 10 of japans population during the feudal era	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
a38c98d7-4143-4efa-9e1b-301047f1db39	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were literate and well-educated they were expected to be cultured and to engage in practices such as tea ceremony and calligraphy	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
f8aeadd0-f746-4ba9-a7dd-215887809ef1	05baa19e-4e92-4e17-b040-66ef9114f2b6	the end of the samurai era also known as the edo period came in the late 19th century during the meiji restoration when the wearing of swords was outlawed and the samurai class was dissolved	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
b7526325-8bef-4f63-ad33-47ea26d490cd	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurais right to be the only armed force was officially abolished in 1876 and replaced by a modern western-style conscripted army	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
42221d64-05d4-4e5b-b3ff-a3366f3a7eb0	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai women also known as onna-bugeisha were trained in the same martial arts and strategy as their male counterparts and fought in combat as well	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
1b0cc532-2062-4186-89ff-d6b5518ec5a1	05baa19e-4e92-4e17-b040-66ef9114f2b6	the word samurai roughly translates to one who serves originally the term referred to men who served as bodyguards to court nobles	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
75c53b20-5f8c-4943-8ccf-0ad835f4b6a8	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were expected to live according to the bushido code also known as the way of the warrior a strict ethical code influenced by confucianism that stressed loyalty to ones master self-discipline and respectful ethical behavior	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
cab13c21-c826-4222-9a46-4641e9e79ad7	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurai were skilled in various martial arts but their main weapon was the katana this sword is uniquely made extremely sharp and considered the soul of the samurai	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
b6519bdc-b926-4b22-a9c2-4266fab7f6be	05baa19e-4e92-4e17-b040-66ef9114f2b6	a samurai was recognized by his carrying the feared daisho the big sword little sword of the warrior these were the battle katana the big sword and the wakizashi the little sword	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
968b485e-7b46-40ec-8302-bc9a0aecfd59	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were allowed to carry their swords into places where commoners could not their swords were so important to their warrior persona that they would even sleep with them and the loss of a sword represented a great dishonor	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
032e8c53-7092-42f1-88a4-a97117534f03	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurai class was abolished by the meiji government in 1868 marking the end of feudalism in japan and the beginning of the modern era	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
b2f1a899-dff0-4c2a-8bef-4318eeea05e2	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the game of basketball was invented by dr james naismith in 1891	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
30a38e32-6170-461b-a61d-2c8caaab460e	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the first basketball game was played with a soccer ball and two peach baskets as goals	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
3471347e-763d-4fd7-afea-3984b62d61c1	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the nba was founded in new york city on june 6 1946 as the basketball association of america baa	AI Generated	\N	t	history	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
468f93f9-e8de-432e-ba77-98719ba37654	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the shortest player ever to play in the nba is tyrone muggsy bogues who is 5 feet 3 inches tall	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
5e2c075e-59e3-453c-96e2-ef20a5d22c87	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the highest scoring nba game was between the detroit pistons and the denver nuggets in 1983 with a final score of 186-184	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
0137a026-7bef-4561-b00f-7ab208c9ddc1	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the womens equivalent of the nba the wnba was founded in 1996	AI Generated	\N	t	history	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
bf1b798e-c30b-4dd3-9d86-2c58f94833a9	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	basketball was invented by dr james naismith in 1891	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
edd92222-346c-4d97-9703-c336eb8c6218	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	michael jordan considered one of the greatest basketball players won six nba championships with the chicago bulls	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
d6a5a001-1a60-4cee-925b-55d0d490356e	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	wilt chamberlain holds the record for the most points scored in a single nba game with 100 points	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
ca778011-7436-4546-b558-4174142bdc52	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the shortest player in the history of the nba is tyrone muggsy bogues who is 5 feet 3 inches tall	AI Generated	\N	t	history	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
2b36a4aa-2234-46fd-85b8-45a4059f0071	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the boston celtics have won the most nba championships with 17 wins	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, "topicId", "canonicalSetId", term, definition, example, source, "sourceUrl", verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "createdAt", "moderationNote", "moderationStatus", "updatedAt", "updatedByAdmin") FROM stdin;
5c98e988-1cfa-4551-8dc5-f34549dc1e2e	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	baseline	A baseline is a line that is a base for measurement or for construction....	The player hit the ball just inside the baseline.	Wikipedia	https://en.wikipedia.org/wiki/Baseline	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
2c71d355-c9af-4b3f-9c26-8e17a902b896	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	deuce	Deuce, Deuces, or The Deuce may refer to:...	The game went to deuce four times before he finally won.	Wikipedia	https://en.wikipedia.org/wiki/Deuce	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
bcd10a1d-7e8f-475c-84f2-3d4d16fcaeca	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	lob	Lob may refer to:...	He hit a perfect lob that landed just inside the baseline.	Wikipedia	https://en.wikipedia.org/wiki/Lob	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
b79483a6-2ce6-4a45-8a27-afd9c3ad5865	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	match point	Match point may refer to:Match point (tennis), won if the player in the lead scores\nMatchpoint scoring, in duplicate bridge\nMatch Point, a 2005 film directed by Woody Allen\nMatchpoint , a 1990 British...	He served an ace on match point to win the tournament.	Wikipedia	https://en.wikipedia.org/wiki/Match_point	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
1fd1bccb-24cd-4e4d-b73d-db2727eb206e	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	rally	Rally or rallye may refer to:...	They had a long rally before he finally hit the ball out.	Wikipedia	https://en.wikipedia.org/wiki/Rally	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
7cff1b6e-044c-45e5-b372-89f806b3b9d5	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	serve	Serve or SERVE may refer to:...	He has one of the fastest serves in the game.	Wikipedia	https://en.wikipedia.org/wiki/Serve	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
1c573840-f7b4-4c56-a935-9e6b6ed1fe96	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	slice	Slice may refer to:Cutting...	He used a slice to make the ball skid and stay low.	Wikipedia	https://en.wikipedia.org/wiki/Slice	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
ac6ee759-bc58-4f74-9a26-17bd85cf0e4d	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	volley	Volley or Volly may refer to:...	She hit a winning volley at the net.	Wikipedia	https://en.wikipedia.org/wiki/Volley	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
f35cdfa1-c8a1-4579-969a-c760d106db26	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	break point	Tennis is a racket sport that is played either individually against a single opponent (singles) or between two teams of two players each (doubles). Each player uses a tennis racket strung with a cord ...	He capitalized on his opponent's double fault and won the break point.	Wikipedia	https://en.wikipedia.org/wiki/Tennis	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
a5eccc4b-a55a-421e-9745-f383122dc383	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	grand slam	Grand Slam or Grand slam may refer to:...	Winning a Grand Slam is the dream of every professional tennis player.	Wikipedia	https://en.wikipedia.org/wiki/Grand_Slam	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
161f8b02-dc90-4461-932d-dc141b40ee29	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	let	Let or LET may refer to:...	The serve was a let, so he had another chance to serve.	Wikipedia	https://en.wikipedia.org/wiki/Let	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
8401ffb4-176d-412e-8f87-c947e66a3cc2	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	tiebreak	In games and sport, a tiebreaker or tiebreak is any method used to determine a winner or to rank participants when there is a tie - meaning two or more parties have achieved a same score or result. A ...	They had to go into a tiebreak to decide the winner of the set.	Wikipedia	https://en.wikipedia.org/wiki/Tiebreaker	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
18f947cf-8b83-4016-b5ba-9e171a84113c	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	unforced error	\nThis page is a glossary of tennis terminology....	His unforced errors cost him the match.	Wikipedia	https://en.wikipedia.org/wiki/Glossary_of_tennis_terms	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
cb979ed6-59cd-485f-a0e0-edfa332f8018	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	anime	Anime  is hand-drawn and computer-generated animation originating from Japan. Outside Japan and in English, anime refers specifically to animation produced in Japan. However, anime, in Japan and in Ja...	'Naruto' and 'Dragon Ball' are popular examples of anime.	Wikipedia	https://en.wikipedia.org/wiki/Anime	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
ed26cbc7-fac4-44f1-8cec-42f881765edb	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	manga	Manga  are comics or graphic novels originating from Japan. Most manga conform to a style developed in Japan in the late 19th century, and the form has a long history in earlier Japanese art. The term...	'Attack on Titan' was originally a manga before being adapted into an anime.	Wikipedia	https://en.wikipedia.org/wiki/Manga	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
b7f6ba16-6ad4-4b3c-86e2-633813827ff4	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	otaku	Otaku  is a type of Japanese subculture of people with consuming interests, such as anime, manga, video games, computers, or any other enthusiastically pursued hobby. Its contemporary use originated w...	John, being an otaku, has a vast collection of anime and manga.	Wikipedia	https://en.wikipedia.org/wiki/Otaku	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
ceb66675-4906-427a-a27d-94e80e6bb4c5	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	double fault	On the x86 architecture, a double fault exception occurs if the processor encounters a problem while trying to service a pending interrupt or exception. An example situation when a double fault would ...	Her double fault cost her the game.	Wikipedia	https://en.wikipedia.org/wiki/Double_fault	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	doesn't have to do with tennis 	rejected	2025-09-09 00:30:46.192	t
83ed027f-3786-4d68-b66e-b81070db41b5	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	cosplay	Cosplay, a blend word of "costume play", is an activity and performance art in which participants called cosplayers wear costumes and fashion accessories to represent a specific character. Cosplayers ...	Many fans enjoy cosplay at anime conventions, embodying their favorite characters.	Wikipedia	https://en.wikipedia.org/wiki/Cosplay	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
72066772-ad26-4d62-9684-7e5ddf91967b	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	shnen	A genre of anime and manga aimed at young boys, often featuring action, adventure, and fighting.	'One Piece' is a well-known shōnen anime.	AI Generated	\N	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
3de755f9-3a5e-4bde-9f96-a2f904f5f22d	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	shjo	A genre of anime and manga aimed at young girls, usually featuring romance and relationships.	'Sailor Moon' is a classic shōjo anime.	AI Generated	\N	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
8cdc186c-b589-4726-967e-180e75ac1bcf	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	seiyuu	Voice acting in Japan is an industry where actors provide voice-overs as characters or narrators in media including anime, video games, audio dramas, commercials, and dubbing for non-Japanese films an...	Popular seiyuu Mamoru Miyano is known for his role in 'Death Note'.	Wikipedia	https://en.wikipedia.org/wiki/Voice_acting_in_Japan	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
c9a15547-dd74-4876-b797-00f3fd17144c	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	hentai	Hentai is a style of Japanese pornographic anime and manga. In addition to anime and manga, hentai works exist in a variety of media, including artwork and video games....	Hentai is a controversial genre within the anime community due to its explicit nature.	Wikipedia	https://en.wikipedia.org/wiki/Hentai	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
01dd1af7-7a3d-4d11-9bd8-80e8e1be3e60	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	chibi	Chibi most often refers to:Chibi (style), a super-deformed diminutive style of Japanese-influenced art, typically with big heads and small bodies.\nChibi, Hubei, a county-level city in southeastern Hub...	Chibi versions of anime characters are often used in promotional materials or merchandise.	Wikipedia	https://en.wikipedia.org/wiki/Chibi	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
cf52dca9-bce6-4d0d-b5e5-64b257760d3d	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	amv	AMV may refer to:...	AMVs are a popular way for fans to express their love for an anime series or pairing.	Wikipedia	https://en.wikipedia.org/wiki/AMV	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
4615b107-e752-45fd-9373-1ff2d3b6c71d	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	ova	The egg cell or ovum is the female reproductive cell, or gamete, in most anisogamous organisms. The term is used when the female gamete is not capable of movement (non-motile). If the male gamete (spe...	'Hellsing Ultimate' is an example of an OVA series.	Wikipedia	https://en.wikipedia.org/wiki/Egg_cell	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
16511af9-9b37-4936-a074-fe4a914a9a86	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	kawaii	Kawaii is a Japanese cultural phenomenon which emphasizes cuteness, childlike innocence, charm, and simplicity. Kawaii culture began to flourish in the 1970s, driven by youth culture and the rise of c...	The 'Hello Kitty' franchise is a perfect example of the kawaii aesthetic.	Wikipedia	https://en.wikipedia.org/wiki/Kawaii	f	t	0.5	general	beginner	2025-09-08 22:26:34.677	\N	pending	2025-09-09 00:09:21.284	f
f98298e2-a1f2-4937-8087-41888ed2bfb1	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	mecha	In science fiction, mecha  or mechs are giant robots or machines, typically depicted as piloted, humanoid walking vehicles. The term was first used in Japanese after shortening the English loanword 'm...	'Gundam' and 'Neon Genesis Evangelion' are popular examples of mecha anime.	Wikipedia	https://en.wikipedia.org/wiki/Mecha	f	t	0.5	general	beginner	2025-09-08 22:26:34.677	\N	pending	2025-09-09 00:09:21.284	f
09efba7c-8d68-4059-8fdd-6b93ba1a82b2	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	samurai	Samurai  were members of the warrior class who served as retainers to lords in Japan prior to the Meiji era. Samurai existed from the late 12th century until their abolition in the late 1870s during t...	The samurai served their daimyo, or feudal lord, with absolute loyalty.	Wikipedia	https://en.wikipedia.org/wiki/Samurai	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
62e4a669-02c7-4254-9451-e75ebc5df382	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	bushido	Bushidō  is a Samurai moral code concerning samurai attitudes, behavior and lifestyle. Its origins date back to the Kamakura period, but it was formalized in the Edo period (1603–1868). There are mult...	Bushido, the way of the warrior, guided the samurai’s conduct in warfare and in peace.	Wikipedia	https://en.wikipedia.org/wiki/Bushido	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
73acfbeb-c28e-4e25-a143-bc612dfc8e94	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	katana	A katana  is a Japanese sword characterized by a curved, single-edged blade with a circular or squared guard and long grip to accommodate two hands. Developed later than the tachi, it was used by samu...	The samurai wielded his katana with skill and precision.	Wikipedia	https://en.wikipedia.org/wiki/Katana	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
79d5e0f9-3fd5-4106-96c9-76e263ad871f	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	seppuku	Seppuku , also called harakiri , is a form of Japanese ritualistic suicide by disembowelment. It was originally reserved for samurai in their code of honor, but was also practiced by other Japanese pe...	The disgraced samurai chose to commit seppuku rather than live with his failure.	Wikipedia	https://en.wikipedia.org/wiki/Seppuku	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
18c7a2a7-61f9-4546-a17e-b6dd7b5e77c0	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	daimyo	Daimyo  were powerful Japanese magnates, feudal lords who, from the 10th century to the early Meiji period in the middle 19th century, ruled most of Japan from their vast hereditary land holdings. The...	The daimyo was a powerful figure, controlling vast territories through his samurai retainers.	Wikipedia	https://en.wikipedia.org/wiki/Daimyo	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
f6dee2b4-6b80-4fa3-809b-f00349748aa0	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	ronin	In feudal Japan to early modern Japan (1185–1868), a rōnin was a samurai who had no lord or master and in some cases, had also severed all links with his family or clan. A samurai became a rōnin upon ...	The ronin wandered the countryside, offering his services as a warrior to the highest bidder.	Wikipedia	https://en.wikipedia.org/wiki/R%C5%8Dnin	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
b463dec6-2146-4634-a242-4867a2c8d875	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	shogun	Shogun , officially seii taishōgun , was the title of the military rulers of Japan during most of the period spanning from 1185 to 1868. Nominally appointed by the Emperor, shoguns were usually the de...	The shogun ruled Japan with an iron fist, directing the actions of the samurai under his command.	Wikipedia	https://en.wikipedia.org/wiki/Shogun	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
b78d809d-d3e7-40bb-ae87-ce023eddceed	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	hakama	Hakama  are a type of traditional Japanese clothing. Originally stemming from Ku, the trousers worn by members of the Chinese imperial court in the Sui and Tang dynasties, this style was adopted by th...	The samurai wore a hakama over his kimono as part of his formal dress.	Wikipedia	https://en.wikipedia.org/wiki/Hakama	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
049cfec2-7f31-41d0-91db-7ee71f0b4d68	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	kendo	Kendo  is a modern Japanese martial art, descended from kenjutsu, that uses bamboo swords (shinai) as well as protective armor (bōgu). It began as samurai warriors' customary swordsmanship exercises, ...	The samurai practiced kendo daily to hone his swordsmanship skills.	Wikipedia	https://en.wikipedia.org/wiki/Kendo	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
79a87018-f796-45e9-9849-f3dd0752d5fd	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	yumi	Yumi  is the Japanese term for a bow. As used in English, yumi refers more specifically to traditional Japanese asymmetrical bows, and includes the longer daikyū  and the shorter hankyū  used in the p...	The samurai trained with the yumi, becoming a skilled archer as well as a swordsman.	Wikipedia	https://en.wikipedia.org/wiki/Yumi	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
0c3a3a49-3ba7-4cad-bdad-137c432cd867	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	dojo	A dōjō  is a hall or place for immersive learning, experiential learning, or meditation. This is traditionally in the field of martial arts. The term literally means "place of the Way" in Japanese....	The samurai spent hours in the dojo, perfecting his martial arts techniques.	Wikipedia	https://en.wikipedia.org/wiki/Dojo	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
bfafdd1d-a4c2-40f6-91c7-bfc774da085d	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	kabuto	Kabuto is a type of helmet first used by ancient Japanese warriors that, in later periods, became an important part of the traditional Japanese armour worn by the samurai class and their retainers in ...	A samurai's kabuto was often elaborately decorated with designs or symbols to signify his clan or family.	Wikipedia	https://en.wikipedia.org/wiki/Kabuto	f	t	0.5	general	beginner	2025-09-08 22:29:32.454	\N	pending	2025-09-09 00:09:21.284	f
8051691d-47fa-4a44-9e00-cf8efcd01f7d	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	dribble	In sports, dribbling is maneuvering a ball by one player while moving in a given direction, avoiding defenders' attempts to intercept the ball. A successful dribble will bring the ball past defenders ...	The point guard was able to dribble past his opponents with ease.	Wikipedia	https://en.wikipedia.org/wiki/Dribbling	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
5870cd1e-2f6b-43be-8acf-f0fb56077bd7	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	rebound	Rebound can refer to:...	The center player was excellent at getting rebounds.	Wikipedia	https://en.wikipedia.org/wiki/Rebound	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
491ba797-e590-41f1-a85b-96b2e8ed73f2	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	free throw	In basketball, free throws or foul shots are unopposed attempts to score points by shooting from behind the free-throw line, a line situated at the end of the restricted area. Free throws are generall...	He was awarded two free throws after being fouled while shooting.	Wikipedia	https://en.wikipedia.org/wiki/Free_throw	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
aea96ef4-8e31-4bdc-9593-c622534a08f1	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	layup	A layup in basketball is a two-point shot attempt made by leaping from below, "laying" the ball up near the basket, and using one hand to bounce it off the backboard and into the basket. The motion an...	The player made a quick layup after beating the defender.	Wikipedia	https://en.wikipedia.org/wiki/Layup	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
2dc59933-81c2-4940-825e-f793f20cbfaf	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	slam dunk	A slam dunk, also simply known as a dunk, is a type of basketball shot that is performed when a player jumps in the air, controls the ball above the horizontal plane of the rim, and shoves the ball di...	The crowd went wild after the player's impressive slam dunk.	Wikipedia	https://en.wikipedia.org/wiki/Slam_dunk	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
5c41fa0a-6ec9-4579-b42d-cfc59ec2e9c3	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	three-point shot	A three-point field goal is a field goal in a basketball game made from beyond the three-point line, a designated arc surrounding the basket. A successful attempt is worth three points, in contrast to...	The guard hit a crucial three-point shot in the last seconds of the game.	Wikipedia	https://en.wikipedia.org/wiki/Three-point_field_goal	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
9c2bfb72-4c97-474e-8ddc-f10607c3f5b5	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	foul	Foul may refer to:...	The player was called for a foul after hitting an opponent's arm while attempting to steal the ball.	Wikipedia	https://en.wikipedia.org/wiki/Foul	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
7477ef65-b4fc-4cbb-a794-cd21d846dfe2	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	block	Block or blocked may refer to:...	The center player made a fantastic block, preventing a sure basket.	Wikipedia	https://en.wikipedia.org/wiki/Block	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
afcb36d1-9095-49ab-98f0-3ae732e23c1c	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	assist	Assist or ASSIST may refer to:...	The point guard had ten assists in the game, demonstrating his great vision and passing skills.	Wikipedia	https://en.wikipedia.org/wiki/Assist	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
0656b427-530b-412e-a9a8-5c791494a876	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	traveling	Travel is the movement of people between distant geographical locations. Travel can be done by foot, bicycle, automobile, train, boat, bus, airplane, ship or other means, with or without luggage, and ...	The referee called traveling on the player who took three steps without dribbling.	Wikipedia	https://en.wikipedia.org/wiki/Travel	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
06718d21-8cf6-41c2-b52f-b3da646f3932	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	dribbling	In sports, dribbling is maneuvering a ball by one player while moving in a given direction, avoiding defenders' attempts to intercept the ball. A successful dribble will bring the ball past defenders ...	The point guard was skilled at dribbling the ball down the court.	Wikipedia	https://en.wikipedia.org/wiki/Dribbling	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
91995c84-9ade-432d-a198-296c77b8af06	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	alley-oop	In basketball, an alley-oop is an offensive play in which one player passes the ball near the basket to a teammate who jumps, catches the ball in mid-air and dunks or lays it in before touching the gr...	The crowd roared in excitement after the successful alley-oop play.	Wikipedia	https://en.wikipedia.org/wiki/Alley-oop	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
702de28e-d633-4549-89a0-1847f17d2c9d	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	double-double	In basketball, a double-double is a single-game performance in which a player accumulates ten or more in two of the following five statistical categories: points, rebounds, assists, steals, and blocke...	The player recorded a double-double with 20 points and 10 rebounds.	Wikipedia	https://en.wikipedia.org/wiki/Double-double	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
38c95ed3-6f72-452c-bca7-431193a86718	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	triple-double	In basketball, a double-double is a single-game performance in which a player accumulates ten or more in two of the following five statistical categories: points, rebounds, assists, steals, and blocke...	The player notched a triple-double with 18 points, 11 assists, and 10 rebounds.	Wikipedia	https://en.wikipedia.org/wiki/Double-double	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
bd7a13b0-4219-4786-bbfb-a2d30bb6e154	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	turnover	Turnover or turn over may refer to:...	The team's high number of turnovers led to their defeat.	Wikipedia	https://en.wikipedia.org/wiki/Turnover	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
7095abac-e118-40a6-b37f-bdfcca9918cc	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	zone defense	Zone defense is a type of defensive system, used in team sports, which is the alternative to man-to-man defense; instead of each player guarding a corresponding player on the other team, each defensiv...	The coach decided to implement a zone defense to counter the opponent's shooting strategy.	Wikipedia	https://en.wikipedia.org/wiki/Zone_defense	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
3fabc69c-74c6-416d-a40c-62ad975b5b6e	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	man-to-man defense	Man-to-man defense, or man defense, is a type of defensive system used in team sports such as American football, association football, basketball and netball, as in which each player is assigned to de...	The team switched to a man-to-man defense to apply more pressure on the opposing team's star player.	Wikipedia	https://en.wikipedia.org/wiki/Man-to-man_defense	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
b21780b7-9ba0-437d-a731-2d669f48aaeb	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	ace	An ace is a playing card, die or domino with a single pip. In the standard French deck, an ace has a single suit symbol located in the middle of the card, sometimes large and decorated, especially in ...	He scored an ace on his first serve.	Wikipedia	https://en.wikipedia.org/wiki/Ace	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	This definition doesn't have to do with tennis	rejected	2025-09-09 00:30:14.537	t
\.


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Topic" (id, name, "canonicalSetId") FROM stdin;
ff520332-6b7f-45bd-a749-ff31b44dd180	tennis	e8871648-d165-4df0-95e7-1c904f2e80e9
535e5d75-e346-4f2b-9522-095f7b452646	anime	59952848-6ca4-41fb-a59a-e05228cf9f06
05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai	6f344c61-c746-439c-8697-542466270031
eab7a23d-a8df-4ea5-9d8d-834a426aaf29	basketball	0e5bd29c-e049-4dce-9800-d094ae95b657
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
78d4c499-5e0e-4e4b-a0e7-f02c1def781e	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	3	2025-09-08 22:25:35.388	2025-09-08 22:25:35.388	2025-09-05 17:29:46.222	2025-09-08 22:41:58.864
\.


--
-- Data for Name: UserTopic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserTopic" (id, "userId", "topicId", weight) FROM stdin;
a24de36d-174f-4c73-863f-06ac41498a0f	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	ff520332-6b7f-45bd-a749-ff31b44dd180	100
68eaadad-d74b-487d-8ec6-1746a6080bf2	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	535e5d75-e346-4f2b-9522-095f7b452646	100
4dd2dd15-4bde-4649-ab74-57f1e0868afb	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	05baa19e-4e92-4e17-b040-66ef9114f2b6	100
46e617ef-7c3a-4aca-8a1b-b9fcbda2fc43	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	100
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
85860666-4a80-42fb-865a-00a4f037a45a	8e2ff6e44db6a6e77c45cbfece6d9e32087c00cc7624af710a08cc7b519a56dc	2025-09-05 17:27:50.87221+00	20250901193144_super_api_migration	\N	\N	2025-09-05 17:27:50.850097+00	1
4f9e4090-0128-4728-8706-d3f7221e8cde	e22239f6ca919da58910c9f2609af0a84750c6cabeae347f95f6cf1f7ea40e2c	2025-09-05 17:27:50.88302+00	20250903062759_quota_add_migration	\N	\N	2025-09-05 17:27:50.874065+00	1
8429832f-a51a-4ac2-b7fa-9096a574889f	50c52370a6841cd655c485dcb07ca9356cad7bb39028e75ca1c3a0213526d160	2025-09-05 17:27:53.383175+00	20250905172753_add_unique_constraints	\N	\N	2025-09-05 17:27:53.374742+00	1
83d86764-1ce4-4a98-8187-019a0a28a283	0e7e677290e1e0b773f11c92b68644f0a9211ec9d14eb9bdcc2d18f3de6bc9d1	2025-09-09 00:09:21.325288+00	20250909000831_add_moderation_fields	\N	\N	2025-09-09 00:09:21.28222+00	1
4677e63d-7a62-45ce-835c-511efed302f3	9dad0a454230914d81813848d789a1825f5ff482c85c259d7a4cc6a8ebdda26e	2025-09-09 00:09:39.102777+00	20250909000939_moderation_migration	\N	\N	2025-09-09 00:09:39.100625+00	1
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

\unrestrict RAbzb3knelfs51Og7DB7sHbZQD6GWc0fwzjEgqyUrx7OJxF9hYcHJkrCB9atyTC

