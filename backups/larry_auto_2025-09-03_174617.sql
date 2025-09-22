--
-- PostgreSQL database dump
--

\restrict L3TR5DyuYpAfb63mVwnDfTsCkIc9cCc11SqdffjAKRMlCXyNJu8rfBgLKyqPxJc

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
\.


--
-- Data for Name: Fact; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Fact" (id, "topicId", fact, source, "sourceUrl", "gptGenerated", category, "createdAt") FROM stdin;
05bb5a78-dae3-486c-bb37-34430f3e1ba4	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	The concept of blockchain was first outlined in 1991 by Stuart Haber and W. Scott Stornetta, two researchers who wanted to implement a system where document timestamps could not be tampered with.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
409e3239-47e1-47ba-b3bc-e115570a5dd7	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain technology gained significant attention due to its application in Bitcoin, the first digital currency to solve the double spending problem without the need of a central authority or server.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
29d973ab-f0f8-4fb4-8c93-c73364890a39	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain transactions are secure, private, and efficient due to their decentralized nature.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
6e8d9276-1725-4f34-8a6f-0e1c0d081d4e	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	The global blockchain market size is expected to reach $20 billion by 2024.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
c6b78c29-78b9-41fb-8dd2-a3f9ebcea4aa	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Estonia is a global leader in blockchain technology, having implemented it for health, judicial, legislative, security and commercial code systems, with plans to extend its use to other spheres like personal medicine, cyber security and data embassies.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
661f91c8-99b9-4b21-bfd2-2c1f7fa3bef7	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	The world's first blockchain-based smartphone, named 'Finney', was created by Sirin Labs, and was launched in November 2018.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
fe635b87-52c6-4245-910b-fb99f6da5686	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain technology is not only used for financial transactions but also for a variety of applications such as supply chain management, digital voting, real estate, and healthcare records.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
c893873c-512e-4b41-8524-10b1ea714732	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	As of February 2022, the Bitcoin market cap is over $900 billion, making it the largest blockchain network.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
f558ff71-aacc-48ae-98ae-a1e762f43cb7	183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum computers could potentially solve certain complex problems much faster than the fastest supercomputers available today.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
2072a6a0-855d-4cec-96a9-ff53beb2036b	183e3db4-3b45-4017-9d95-ca93cf4ca582	The concept of quantum computing was first introduced by physicist Richard Feynman in 1982.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
ea8610ec-9bbf-4f16-82f2-dee5a147d2da	183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum computers do not use binary logic. Instead, they use the principles of quantum mechanics to process information.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
2043ebe5-6586-4c0f-863d-a5dd7ff831bb	183e3db4-3b45-4017-9d95-ca93cf4ca582	In 2019, Google announced that it had achieved 'quantum supremacy' with a 53-qubit quantum computer.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
1793e03f-862a-4262-98f9-4f10ef0ce077	183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum computers could revolutionize fields such as cryptography, material science, and artificial intelligence.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
d1f8e6c4-f47d-4509-bb49-fa60ef311195	183e3db4-3b45-4017-9d95-ca93cf4ca582	Currently, maintaining the stability of qubits is one of the biggest challenges in quantum computing.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
de90f8a4-9b20-4eea-9a4b-7f10fbeb0a06	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	The concept of machine learning was first proposed by Arthur Samuel in 1959.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
405a998e-51ec-4dea-b773-4a3379eff842	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	One of the earliest applications of machine learning was in the game of checkers where a computer program learned to improve its performance by playing games against itself.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
139d93f9-0717-4b71-a0b6-238ce5a8138c	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine learning is used in a wide range of applications including email filtering, detection of network intruders, medical diagnosis, stock trading and speech recognition.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
620fc78b-24a5-40c3-97f7-83b1a7022784	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Deep learning, a subset of machine learning, is based on artificial neural networks which are designed to simulate the way the human brain works.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
45d91342-b454-4894-aa5d-1245495bc96b	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine learning algorithms can identify patterns in data and make predictions much faster and more accurately than humans can.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
65c7a5e0-51ba-4742-90a8-c5c22e031828	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	The increase in the amount of digital data available for analysis has been one of the main drivers of the recent growth in the use of machine learning.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
a7e1627c-c088-4384-a5aa-7a6f3a83de55	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine learning is an essential part of artificial intelligence (AI). It provides AI with the ability to learn, improvise and evolve with experience.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
95676bfa-374a-426d-a204-5f1db2c14673	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine Learning is heavily used by search engines to improve their performance in delivering more accurate results.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
9dc5d057-3a67-493b-9985-33c216fea30e	04842c35-0266-43f1-9d72-85d9c54ba6b5	The term 'Artificial Intelligence' was first coined by John McCarthy in 1956.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
5d7115a3-c13c-4aec-b577-266cb0b55b4c	04842c35-0266-43f1-9d72-85d9c54ba6b5	AI can be classified into two types: Narrow AI, which is designed to perform a narrow task (such as facial recognition or internet searches) and General AI, which can perform any intellectual task that a human being can do.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
cd7f8842-c7f9-4090-8cf2-6bdaf3f1306c	04842c35-0266-43f1-9d72-85d9c54ba6b5	Artificial Intelligence can work 24/7 without any breaks and it does not get bored unlike humans.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
be027a05-7244-467c-bad5-281f0b384459	04842c35-0266-43f1-9d72-85d9c54ba6b5	AI is being used in a wide variety of fields including healthcare, finance, transportation, and entertainment.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
3de802d3-f072-41f4-a4ef-6480d79f4d77	04842c35-0266-43f1-9d72-85d9c54ba6b5	As per the World Intellectual Property Organization, over half of the patent applications for AI technologies have been filed in the last five years.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
c0133742-2f44-4375-992e-17f4402cc55e	04842c35-0266-43f1-9d72-85d9c54ba6b5	A type of AI called 'Predictive AI' is being used to predict and prevent cyberattacks in real-time.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
42fdf34b-4b3d-4dbb-8be1-c21405f505e4	cc553f3c-f717-44cc-af15-56baba255b3c	The first ever website was published on August 6, 1991 by British physicist Tim Berners-Lee.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
ce623003-09a4-42a2-83d8-d362f8847726	cc553f3c-f717-44cc-af15-56baba255b3c	JavaScript was created in just 10 days. In May 1995, Brendan Eich wrote the first version of JavaScript in 10 days while working at Netscape.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
9dca3dde-e1a3-4c6c-9091-cc1ab4aa04e9	cc553f3c-f717-44cc-af15-56baba255b3c	The 'www' part of a web address stands for 'World Wide Web' which is a term that represents the system we use to access the internet.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
1c9e439b-6ec1-4b39-8e91-a3dc1021c51f	cc553f3c-f717-44cc-af15-56baba255b3c	The original HTML, created by Tim Berners-Lee, had only 20 elements. Today's HTML5 has 140.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
95e0e2ff-9e7b-46d8-bdf5-539a0e966f75	cc553f3c-f717-44cc-af15-56baba255b3c	CSS was first proposed by Håkon Wium Lie on October 10, 1994. At the time, Lie was working with Tim Berners-Lee at CERN.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
c8d7fdcf-dae8-48be-8ce2-48ac70bff609	cc553f3c-f717-44cc-af15-56baba255b3c	As of January 2021, there are over 1.8 billion websites on the internet, although less than 200 million are active.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
9061bbaa-d9c5-41f0-85bc-6c3b6585d0e7	cc553f3c-f717-44cc-af15-56baba255b3c	The most popular content management system (CMS) for website building is WordPress, which powers over 35% of all the websites on the Internet.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
6e54476e-521f-490e-86b7-c3ed8b5f93d1	6a141c53-2608-427e-b3a4-64957e874a60	Harvard Business Review named 'Data Scientist' the 'Sexiest Job of the 21st Century'.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
8c2b3c0b-9bf0-452e-bae4-a900845bc860	6a141c53-2608-427e-b3a4-64957e874a60	The term 'Data Science' has been around since the early 1960s and was first used by Peter Naur in 1960.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
bc9b45ec-2a70-4b9e-ab3d-509d63db97fb	6a141c53-2608-427e-b3a4-64957e874a60	By 2025, it's predicted that there will be 175 zettabytes (175 billion terabytes) of data worldwide, up from just 33 zettabytes in 2018.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
f694fde1-5a00-44ac-9ec6-f94c9184404a	6a141c53-2608-427e-b3a4-64957e874a60	Data scientists spend about 60% of their time cleaning and organizing data.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
2294038e-7b1c-467b-8d80-10834d685e20	6a141c53-2608-427e-b3a4-64957e874a60	In the United States, data scientists earn an average salary of $120,000 per year.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
83e17839-7563-4510-8861-bba187531d5e	6a141c53-2608-427e-b3a4-64957e874a60	Data science is applicable in various fields including healthcare, finance, retail, transport, and more.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
67fdd0e6-51e7-45c0-99fa-b457e249a414	e16ddde0-0620-440d-99d1-99c9c86fc8d9	Test quotas are often used in educational institutions to manage the number of assessments given to students.	AI Generated	\N	t	general	2025-09-03 06:50:45.305
7674c571-78e3-48e8-9f99-3d6e155a1417	e16ddde0-0620-440d-99d1-99c9c86fc8d9	Test quotas can also be set in software testing environments to maintain efficiency and avoid overload.	AI Generated	\N	t	general	2025-09-03 06:50:45.305
56d7c8ce-4dbe-4ed5-be34-f04d812a0a8a	e16ddde0-0620-440d-99d1-99c9c86fc8d9	Exceeding a test quota can result in negative consequences such as system crashes or reduced test integrity.	AI Generated	\N	t	general	2025-09-03 06:50:45.305
2760b1a9-70ef-42b3-b411-db831889409b	e16ddde0-0620-440d-99d1-99c9c86fc8d9	Proper test quota management can contribute to better test performance and improved resource allocation.	AI Generated	\N	t	general	2025-09-03 06:50:45.305
01d253b5-c520-4ec4-ad94-88fee496fb35	e16ddde0-0620-440d-99d1-99c9c86fc8d9	Test quotas are typically set based on factors such as resource availability, system capacity, and the purpose of the tests.	AI Generated	\N	t	general	2025-09-03 06:50:45.305
bc66f9b7-c8a2-4766-af3a-12fc8e32879d	e16ddde0-0620-440d-99d1-99c9c86fc8d9	Test quotas are often used in COVID-19 testing to manage the number of tests that can be performed each day.	AI Generated	\N	t	general	2025-09-03 06:50:45.305
54728a50-a128-406c-baaf-15688c9f74f6	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	Test quotas are often used in load testing to simulate high usage scenarios and see how the system performs.	AI Generated	\N	t	general	2025-09-03 06:51:22.343
9d63261a-6f62-477a-b59f-ea7ad5f51851	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	The concept of Test Quota is also used in academic testing environments, where it refers to a predefined limit on the number of tests a student can attempt.	AI Generated	\N	t	general	2025-09-03 06:51:22.343
4b5990a1-97e8-4057-86d9-d4c1e2eb4e50	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	Test quotas can be useful in managing and controlling the testing process, ensuring that it is thorough yet efficient.	AI Generated	\N	t	general	2025-09-03 06:51:22.343
3c08aaef-754c-46d3-a5ee-175cf973368d	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	In software testing, exceeding the test quota may result in extra costs, depending on the testing platform used.	AI Generated	\N	t	general	2025-09-03 06:51:22.343
33dbed83-59e6-4478-8d20-5f54d7504716	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	Test quotas are often set based on the complexity of the software, the potential user load, and the risk associated with failure.	AI Generated	\N	t	general	2025-09-03 06:51:22.343
95af527f-5798-4546-823a-0835620d9515	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	Test quotas can be revised and adjusted based on the results of initial tests and changes in requirements or objectives.	AI Generated	\N	t	general	2025-09-03 06:51:22.343
94dfb677-c8a7-4466-80c4-6cacd952ec68	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	Test Quota can help in preventing system overload by limiting the number of tests run within a specific time period.	AI Generated	\N	t	general	2025-09-03 06:52:15.439
5bfd719f-efe9-4e6e-b770-831ffdca6709	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	Test Quota helps in prioritizing test cases, ensuring that important tests are run within the designated quota.	AI Generated	\N	t	general	2025-09-03 06:52:15.439
19c4433a-45c5-4e75-8899-36bc5181637a	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	Test Quota is an important parameter in performance and load testing, helping to ensure that the system can handle the specified load.	AI Generated	\N	t	general	2025-09-03 06:52:15.439
0e89ca49-65f9-4220-a109-10237726ba99	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	A well-defined Test Quota can contribute to efficient use of resources, ensuring that testing does not consume excessive system resources.	AI Generated	\N	t	general	2025-09-03 06:52:15.439
faa5ef1e-6500-42de-80b6-8600db1155b3	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	Test Quota can help to maintain a balance between thorough testing and efficient use of time and resources.	AI Generated	\N	t	general	2025-09-03 06:52:15.439
51adf3b5-cb87-4d13-a1a0-f6ace7762818	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	The concept of Test Quota is often used in cloud-based testing platforms, where resources are limited and must be shared among multiple users.	AI Generated	\N	t	general	2025-09-03 06:52:15.439
04f8aba9-f8d5-485e-abc7-45b461a769a1	8f37e7c1-b91a-4745-918b-1f1567778e5b	HTML was first created in 1990, and is still the cornerstone of web content structure today.	AI Generated	\N	t	general	2025-09-03 16:05:10.962
c005df91-46dc-45ef-8cca-469ffa938594	8f37e7c1-b91a-4745-918b-1f1567778e5b	The term 'Responsive Design' was first coined by Ethan Marcotte in a 2010 article on A List Apart.	AI Generated	\N	t	general	2025-09-03 16:05:10.962
07740fcf-bb55-4d87-93d4-b9d012831f15	8f37e7c1-b91a-4745-918b-1f1567778e5b	JavaScript was initially created in just 10 days by Brendan Eich in 1995. It has since become one of the core technologies of the web, alongside HTML and CSS.	AI Generated	\N	t	general	2025-09-03 16:05:10.962
8fd0f933-52b8-4818-9db3-b9d992298c0c	8f37e7c1-b91a-4745-918b-1f1567778e5b	In 2020, there were over 1.7 billion websites on the Internet, all of which required some level of web development.	AI Generated	\N	t	general	2025-09-03 16:05:10.962
941fc448-8cfa-42d8-85d7-41932c66f86c	8f37e7c1-b91a-4745-918b-1f1567778e5b	The first ever website was published on August 6, 1991 by British physicist Tim Berners-Lee. It was dedicated to information on the World Wide Web project and was made by Berners-Lee while at CERN, the European physics research center.	AI Generated	\N	t	general	2025-09-03 16:05:10.962
20fdaa12-5950-4174-9882-e906d28bad81	8f37e7c1-b91a-4745-918b-1f1567778e5b	APIs are a crucial part of the web today, enabling the integration of different services and allowing for the creation of complex, feature-rich applications.	AI Generated	\N	t	general	2025-09-03 16:05:10.962
ae312042-064e-42d3-9653-05828260c517	0a13eaab-9475-4f95-be1f-03aa033fbe56	Enterprise companies are often multinational, operating in multiple countries around the globe.	AI Generated	\N	t	general	2025-09-03 16:20:47.357
c1c65ca2-e28a-4a86-ac7a-6e98316d4553	0a13eaab-9475-4f95-be1f-03aa033fbe56	The largest global enterprise by revenue is currently Walmart, with over $500 billion in revenue per year.	AI Generated	\N	t	general	2025-09-03 16:20:47.357
1953871c-0497-475d-b75d-4305e7fa3ab3	0a13eaab-9475-4f95-be1f-03aa033fbe56	Enterprises often have thousands, or even hundreds of thousands, of employees.	AI Generated	\N	t	general	2025-09-03 16:20:47.357
548144c2-e495-49f3-ae1e-1550e397b9c3	0a13eaab-9475-4f95-be1f-03aa033fbe56	Corporate culture can greatly affect an enterprise's success. A positive, inclusive culture can lead to higher employee satisfaction and productivity.	AI Generated	\N	t	general	2025-09-03 16:20:47.357
bb2c96ec-90f0-4244-a546-2419f64fa84c	0a13eaab-9475-4f95-be1f-03aa033fbe56	Entrepreneurs often start small businesses that can grow into large enterprises. For example, Jeff Bezos started Amazon as a small online bookstore.	AI Generated	\N	t	general	2025-09-03 16:20:47.357
87e7f2bd-e02d-480f-bbb7-821a28fd474f	0a13eaab-9475-4f95-be1f-03aa033fbe56	In a global enterprise, managing the supply chain can be a major challenge due to the complexity of dealing with suppliers and customers in different countries and time zones.	AI Generated	\N	t	general	2025-09-03 16:20:47.357
9b95157c-657f-4368-a706-657eec852ffd	97a012d4-c329-4809-bd5f-70e7e5c812fc	Enterprise Resource Planning (ERP) systems are used by organizations looking to manage their business functions within a centralized and integrated system.	AI Generated	\N	t	general	2025-09-03 16:20:58.553
5cbba876-c613-4858-a8a8-7cb4b58fdd45	97a012d4-c329-4809-bd5f-70e7e5c812fc	Enterprise Software is also known as enterprise application software (EAS).	AI Generated	\N	t	general	2025-09-03 16:20:58.553
97c24db5-8826-4845-b809-7fb074d92639	97a012d4-c329-4809-bd5f-70e7e5c812fc	CRM systems are used to streamline processes, build customer relationships, increase sales, improve customer service, and increase profitability.	AI Generated	\N	t	general	2025-09-03 16:20:58.553
5d4142fe-a3e7-4396-9c2f-9a9ae25c73c7	97a012d4-c329-4809-bd5f-70e7e5c812fc	The global enterprise software market size was valued at USD 575.4 billion in 2020 and is expected to expand at a compound annual growth rate (CAGR) of 10.5% from 2021 to 2028.	AI Generated	\N	t	general	2025-09-03 16:20:58.553
9e2a5805-f7bd-452b-8695-318834ff083b	97a012d4-c329-4809-bd5f-70e7e5c812fc	Enterprise Architecture (EA) is often used to create a map or blueprint of the organization, including its processes, systems, information and technologies.	AI Generated	\N	t	general	2025-09-03 16:20:58.553
27735559-e691-439e-ab28-3623f362084d	97a012d4-c329-4809-bd5f-70e7e5c812fc	Supply Chain Management (SCM) involves coordinating and integrating these flows both within and among companies to achieve efficient and effective supply chain operations.	AI Generated	\N	t	general	2025-09-03 16:20:58.553
c12cda32-e4ef-4ccb-a620-77e9289487fc	97a012d4-c329-4809-bd5f-70e7e5c812fc	Enterprise Data Management (EDM) is an important facet of IT strategy, as it ensures data is accurate, consistent, and readily available to support business operations and strategic decisions.	AI Generated	\N	t	general	2025-09-03 16:20:58.553
76e0df08-231b-450c-b2c1-5d2ebffd4839	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	Enterprise Resource Planning (ERP) systems were first introduced in the 1960s to facilitate large-scale manufacturing processes.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
2b7a534b-400b-4aca-be45-a1f21ebf0358	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	The first Customer Relationship Management (CRM) systems were developed in the 1980s as a response to the need for sales automation.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
e62080ef-5c07-47f5-b03a-cc1c2c4153ca	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	In 2019, the global supply chain management market was valued at USD 15.85 billion and is expected to expand at a compound annual growth rate (CAGR) of 11.2% from 2020 to 2027.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
10500cbe-d196-4a43-9f2e-dc7d264c1a99	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	Business Intelligence (BI) technologies can handle large amounts of structured and sometimes unstructured data to identify, develop and create new strategic business opportunities.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
7110d28b-cc9f-4d7f-811b-d22dd758bfc5	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	According to Gartner, the Software as a Service (SaaS) market reached $85 billion in revenue in 2019, a 20% increase from 2018.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
a43dc30e-2cf9-4c57-a949-6efc3c620a97	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	E-commerce sales are projected to reach $6.54 trillion in 2022, up from $3.53 trillion in 2019.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
8af71fcf-2a91-423e-bfd6-7485b32e513d	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	Mobile commerce, also known as m-commerce, is rapidly growing with a recent study showing that 45% of all e-commerce transactions will be done on mobile devices by the end of 2020.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
420724b2-1210-42cc-9de6-908fbc99633f	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	Cloud Computing is expected to become a $832.1 billion market by 2025.	AI Generated	\N	t	general	2025-09-03 16:21:12.605
391a1269-2c93-4285-99ae-a9e303c6058f	07b81f70-6b02-4afe-94e6-6aa07a0f3203	According to a report by Statista, the global ERP software market is expected to reach $49.5 billion by 2025.	AI Generated	\N	t	general	2025-09-03 16:22:04.835
d3c79a4f-83c5-4595-a584-6bc75a3d24fb	07b81f70-6b02-4afe-94e6-6aa07a0f3203	Gartner forecasted that the worldwide public cloud services market would grow by 17.3% in 2019 to total $206.2 billion, up from $175.8 billion in 2018.	AI Generated	\N	t	general	2025-09-03 16:22:04.835
4b263ceb-896c-467d-92cf-2590eae898f8	07b81f70-6b02-4afe-94e6-6aa07a0f3203	According to Salesforce, 75% of people now expect a consistent experience wherever they engage with brands – be it through social media, mobile, or even in person.	AI Generated	\N	t	general	2025-09-03 16:22:04.835
e07afc79-c602-42ec-b941-165c0fb1f1a0	07b81f70-6b02-4afe-94e6-6aa07a0f3203	According to a study by Accenture, 76% of business leaders believe that current business models will be unrecognizable in the next five years — with ecosystems being the main change agent.	AI Generated	\N	t	general	2025-09-03 16:22:04.835
41d9eccf-c731-4fae-94ff-ef2c3d3b67ca	07b81f70-6b02-4afe-94e6-6aa07a0f3203	According to International Data Corporation (IDC), big data and business analytics worldwide revenues will surpass $210 billion in 2020.	AI Generated	\N	t	general	2025-09-03 16:22:04.835
6bc8aadc-0c8d-44a8-ae34-52d5a2a9129b	7052e099-683a-40f0-a587-ecc5f03f578d	According to Salesforce, 75% of consumers expect companies to use new technologies to create better experiences.	AI Generated	\N	t	general	2025-09-03 16:22:17.834
b3c8ef79-3f54-47ce-a815-1494f0409575	7052e099-683a-40f0-a587-ecc5f03f578d	As per Gartner, worldwide end-user spending on public cloud services is forecast to grow 23.1% in 2021 to total $332.3 billion.	AI Generated	\N	t	general	2025-09-03 16:22:17.834
ed64178a-e72d-4a76-b7e8-9ecb7ca1c71a	7052e099-683a-40f0-a587-ecc5f03f578d	According to IDC, the amount of data in the world will grow to 175 zettabytes by 2025.	AI Generated	\N	t	general	2025-09-03 16:22:17.834
f92915f3-e5f0-4002-87c7-130f897ca507	7052e099-683a-40f0-a587-ecc5f03f578d	As reported by McKinsey, AI could potentially deliver additional economic output of around $13 trillion by 2030, boosting global GDP by about 1.2% a year.	AI Generated	\N	t	general	2025-09-03 16:22:17.834
0aa72c2f-bcdc-4265-b369-dbe0d12c7703	7052e099-683a-40f0-a587-ecc5f03f578d	According to Gartner, by 2022, 70% of enterprises will be experimenting with immersive technologies for consumer and enterprise use, and 25% will have deployed them to production.	AI Generated	\N	t	general	2025-09-03 16:22:17.834
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, "topicId", "canonicalSetId", term, definition, example, source, "sourceUrl", verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "createdAt") FROM stdin;
74cb0cbc-fb9c-4bd7-8836-ea3da3504b66	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Blockchain	The blockchain is a distributed ledger with growing lists of records (blocks) that are securely linked together via cryptographic hashes. Each block contains a cryptographic hash of the previous block...	Bitcoin uses blockchain technology to record transactions.	Wikipedia	https://en.wikipedia.org/wiki/Blockchain	t	f	1	general	advanced	2025-09-03 03:55:33.309
a75761b2-2f71-44d8-b5b6-dc24c6f9196c	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Cryptocurrency	A cryptocurrency is a digital currency designed to work through a computer network that is not reliant on any central authority, such as a government or bank, to uphold or maintain it. However, a type...	Bitcoin and Ethereum are examples of cryptocurrencies.	Wikipedia	https://en.wikipedia.org/wiki/Cryptocurrency	t	f	1	general	advanced	2025-09-03 03:55:33.309
8ff14690-bdc5-4223-8069-57a08d7aaf1d	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Decentralization	Decentralization or decentralisation is the process by which the activities of an organization, particularly those related to planning and decision-making, are distributed or delegated away from a cen...	Blockchain technology is often praised for its decentralization, which makes it resistant to control by any single entity.	Wikipedia	https://en.wikipedia.org/wiki/Decentralization	t	f	1	general	advanced	2025-09-03 03:55:33.309
2de1112b-5aad-4d8b-9a71-b8944ff523ad	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Smart Contract	\nA smart contract is a computer program or a transaction protocol that is intended to automatically execute, control or document events and actions according to the terms of a contract or an agreement...	Ethereum blockchain is known for its smart contract functionality.	Wikipedia	https://en.wikipedia.org/wiki/Smart_contract	t	f	1	general	advanced	2025-09-03 03:55:33.309
cbe8a057-e3ab-4834-a717-1b3e7e9a4f32	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Mining	Mining is the extraction of valuable geological materials and minerals from the surface of the Earth. Mining is required to obtain most materials that cannot be grown through agricultural processes, o...	Bitcoin mining involves solving complex mathematical problems to add a new block to the blockchain.	Wikipedia	https://en.wikipedia.org/wiki/Mining	t	f	1	general	advanced	2025-09-03 03:55:33.309
8f595b2e-f4e3-4983-923e-b54d652de9e8	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Block	Block or blocked may refer to:...	In the Bitcoin blockchain, a new block is added approximately every 10 minutes.	Wikipedia	https://en.wikipedia.org/wiki/Block	t	f	1	general	beginner	2025-09-03 03:55:33.309
cb3fb8b3-b130-48a5-93df-5e17cc9d215a	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Node	In general, a node is a localized swelling or a point of intersection....	In a decentralized blockchain, every node has a copy of the entire blockchain.	Wikipedia	https://en.wikipedia.org/wiki/Node	t	f	1	general	beginner	2025-09-03 03:55:33.309
12e27bcf-8575-45b5-89bb-b1cd372d0100	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Public Key	A cryptographic key that can be utilized by any party to encrypt a message. Another party can then receive the message and using a key that only they know (the private key), decode the message.	In blockchain, public keys are used as the addresses where transactions can be sent.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 03:55:33.309
d4372cd4-7905-4f94-a11e-a95fed045bc6	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Private Key	A secret key that is used in the decryption or creation of a digital signature.	In blockchain, a private key is used to sign transactions and access one's cryptocurrency holdings.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 03:55:33.309
7dcf733c-be8c-4b81-aab5-cb0fd5fbb265	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Hash	Hash, hashes, hash mark, or hashing may refer to:...	In blockchain, a cryptographic hash function is used to secure data.	Wikipedia	https://en.wikipedia.org/wiki/Hash	t	f	1	general	beginner	2025-09-03 03:55:33.309
37d9cf86-cccb-4d82-ae9e-0d11738ce48e	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Computing	A quantum computer is a computer that uses quantum mechanical phenomena in an essential way: it exploits superposed and entangled states, and the intrinsically non-deterministic outcomes of quantum me...	Quantum computing could potentially solve complex problems much faster than traditional computing.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_computing	t	f	1	general	advanced	2025-09-03 05:30:19.259
f8f5ddf0-3840-4e54-945c-f14e1683f0b9	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Qubit	In quantum computing, a qubit or quantum bit is a basic unit of quantum information—the quantum version of the classic binary bit physically realized with a two-state device. A qubit is a two-state qu...	A qubit can exist in a state of 0, 1, or both at the same time.	Wikipedia	https://en.wikipedia.org/wiki/Qubit	t	f	1	general	advanced	2025-09-03 05:30:19.259
e5df381b-d605-4249-847a-7d0c226bbf44	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Superposition	In mathematics, a linear combination or superposition is an expression constructed from a set of terms by multiplying each term by a constant and adding the results. The concept of linear combinations...	In quantum computing, a qubit can be in a state of superposition, existing as both 0 and 1 simultaneously.	Wikipedia	https://en.wikipedia.org/wiki/Linear_combination	t	f	1	general	advanced	2025-09-03 05:30:19.259
94101aea-51df-487e-a2cf-1bdccfa69529	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Entanglement	Entanglement may refer to:Quantum entanglement\nOrientation entanglement\nEntanglement \nEntanglement of polymer chains, see Reptation\nWire entanglement\nin fishery: method by which fish are caught in fis...	Quantum entanglement is a key principle that allows quantum computers to process massive amounts of data simultaneously.	Wikipedia	https://en.wikipedia.org/wiki/Entanglement	t	f	1	technique	advanced	2025-09-03 05:30:19.259
e7ce20de-44f9-490c-858d-5e5ba1d6aeed	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Circuit	A sequence of basic quantum gates or operations that are applied to qubits to perform a quantum computation.	The design of a quantum circuit is crucial for the efficient operation of a quantum computer.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 05:30:19.259
abf63738-6821-40ec-aa95-4d515811ecca	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Gate	\nIn quantum computing and specifically the quantum circuit model of computation, a quantum logic gate is a basic quantum circuit operating on a small number of qubits. Quantum logic gates are the buil...	Quantum gates manipulate the state of qubits and are used to perform quantum algorithms.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_logic_gate	t	f	1	general	advanced	2025-09-03 05:30:19.259
42150f7d-d03d-45bc-b273-c0cd4968e5d8	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Algorithm	A step-by-step procedure of quantum operations that can be performed on a quantum computer.	Shor's algorithm, a quantum algorithm, can factor large numbers more efficiently than classical computers.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 05:30:19.259
32cac6c5-aa99-4ae4-8f5e-02c560fb0803	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Supremacy	Quantum Supremacy: How the Quantum Computer Revolution Will Change Everything is a non-fiction book by the American futurist and physicist Michio Kaku. The book, Kaku's eleventh, was initially publish...	In 2019, Google claimed to have achieved quantum supremacy with its Sycamore quantum processor.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_Supremacy	t	f	1	general	advanced	2025-09-03 05:30:19.259
14142a26-f243-4a16-afb1-fbe0803b1c87	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum State	In quantum physics, a quantum state is a mathematical entity that embodies the knowledge of a quantum system. Quantum mechanics specifies the construction, evolution, and measurement of a quantum stat...	In quantum computing, computations are performed by manipulating the quantum state of the system.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_state	t	f	1	general	advanced	2025-09-03 05:30:19.259
e5a440a7-acff-4104-b664-8e9a0f215b06	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Decoherence	Quantum decoherence is the loss of quantum coherence. It involves generally a loss of information of a system to its environment. Quantum decoherence has been studied to understand how quantum systems...	Decoherence is a major challenge in building practical quantum computers as it leads to errors in computations.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_decoherence	t	f	1	general	advanced	2025-09-03 05:30:19.259
4505210d-8086-438d-84e4-13ca281b8237	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Machine Learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	Email spam filtering is an example of machine learning where the algorithm learns to classify emails as 'spam' or 'not spam'.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	t	f	1	general	advanced	2025-09-03 05:43:04.407
c56a8930-4213-48e2-9901-3891812a2ac6	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Supervised Learning	A type of machine learning where the model is trained on a labelled dataset. Each example in the dataset is a pair consisting of an input vector and a desired output value.	A supervised learning algorithm can be used to train a model that predicts house prices based on features like location, size, and condition.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 05:43:04.407
4043f04e-b3b5-4ce5-9c96-2a822cfa8196	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Unsupervised Learning	A type of machine learning where the model is trained on an unlabelled dataset and the goal is to find structure in the data.	Clustering is a common unsupervised learning task where the algorithm groups similar data together.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 05:43:04.407
8fb24fe3-d7f3-4f7b-bae0-55acc45e4c98	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Reinforcement Learning	Reinforcement learning (RL) is an interdisciplinary area of machine learning and optimal control concerned with how an intelligent agent should take actions in a dynamic environment in order to maximi...	Reinforcement learning is used to train self-driving cars by rewarding the system for safe driving and penalizing it for dangerous actions.	Wikipedia	https://en.wikipedia.org/wiki/Reinforcement_learning	t	f	1	general	advanced	2025-09-03 05:43:04.407
5b0b228e-0045-4250-917d-af9ef73b0f3d	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Neural Networks	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Neural networks are used in image recognition systems to identify objects in a picture.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	t	f	1	general	advanced	2025-09-03 05:43:04.407
9c1c4a2d-d117-4b08-a399-6db437651ce2	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Deep Learning	In machine learning, deep learning focuses on utilizing multilayered neural networks to perform tasks such as classification, regression, and representation learning. The field takes inspiration from ...	Deep learning is used in speech recognition systems like Amazon's Alexa or Apple's Siri.	Wikipedia	https://en.wikipedia.org/wiki/Deep_learning	t	f	1	general	advanced	2025-09-03 05:43:04.407
806119a4-cac1-406e-bc36-575b2869dd89	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Regression	Regression or regressions may refer to:...	Linear regression is used to predict a person's weight based on their height.	Wikipedia	https://en.wikipedia.org/wiki/Regression	t	f	1	general	beginner	2025-09-03 05:43:04.407
fea0c0ba-7d66-4684-89bd-113f5a13f20a	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Classification	Classification is the activity of assigning objects to some pre-existing classes or categories. This is distinct from the task of establishing the classes themselves. Examples include diagnostic tests...	A classification algorithm can be used to identify whether an email is spam or not.	Wikipedia	https://en.wikipedia.org/wiki/Classification	t	f	1	general	advanced	2025-09-03 05:43:04.407
cfb0f2f5-a367-47cc-bb29-81a2053011db	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Overfitting	In mathematical modeling, overfitting is "the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit to additional data or predict...	A complex machine learning model may overfit if it has too many parameters relative to the number of observations.	Wikipedia	https://en.wikipedia.org/wiki/Overfitting	t	f	1	general	advanced	2025-09-03 05:43:04.407
046f217e-bba1-4a1c-bd9f-231a83cc5478	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Underfitting	In mathematical modeling, overfitting is "the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit to additional data or predict...	A linear model may underfit a dataset that has a non-linear relationship.	Wikipedia	https://en.wikipedia.org/wiki/Overfitting	t	f	1	general	advanced	2025-09-03 05:43:04.407
41cfc433-7a5d-4f4f-8f29-7d095c6fad37	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Feature Extraction	The process of transforming raw data into features that can be used to improve the performance of machine learning algorithms.	In image recognition, feature extraction may involve identifying shapes or textures in the image.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 05:43:04.407
a6bf1f8f-f5b3-4f63-90b2-e4dd2e73f811	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Dataset	A data set is a collection of data. In the case of tabular data, a data set corresponds to one or more database tables, where every column of a table represents a particular variable, and each row cor...	A dataset for a machine learning project might include information like age, gender, and income to predict credit risk.	Wikipedia	https://en.wikipedia.org/wiki/Data_set	t	f	1	general	advanced	2025-09-03 05:43:04.407
0adcf30f-232a-41f8-8f39-9ecedc82a828	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Model Training	The process of determining the best model, or the best parameters for a model, through iterative learning from data.	Model training involves using a machine learning algorithm to learn the relationships between independent and dependent variables.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 05:43:04.407
1d07fdd7-44d5-4a84-9455-04bfa6e37d66	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Prediction	A prediction or  forecast is a statement about a future event or about future data. Predictions are often, but not always, based upon experience or knowledge of forecasters. There is no universal agre...	After training a machine learning model on weather data, the prediction might be whether or not it will rain tomorrow.	Wikipedia	https://en.wikipedia.org/wiki/Prediction	t	f	1	general	advanced	2025-09-03 05:43:04.407
b74a7743-5b95-4629-aaa0-51191af4a021	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Hyperparameter	Hyperparameter may refer to:Hyperparameter \nHyperparameter \n\n...	The learning rate is a common hyperparameter that determines the step size at each iteration while moving toward a minimum of a loss function.	Wikipedia	https://en.wikipedia.org/wiki/Hyperparameter	t	f	1	general	advanced	2025-09-03 05:43:04.407
398c2308-12b7-45bf-8e4d-d6e3a35d0c68	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Artificial Intelligence (AI)	Artificial intelligence (AI) is the capability of computational systems to perform tasks typically associated with human intelligence, such as learning, reasoning, problem-solving, perception, and dec...	Siri, the virtual assistant on iPhones, is a form of artificial intelligence.	Wikipedia	https://en.wikipedia.org/wiki/Artificial_intelligence	t	f	1	general	advanced	2025-09-03 06:01:54.413
8c5b7d4c-3275-49be-9e66-277ecdeded21	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Machine Learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	Netflix uses machine learning algorithms to recommend movies based on a user's viewing history.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	t	f	1	general	advanced	2025-09-03 06:01:54.413
55f184e6-4205-46ab-96ab-5b06d4d9728d	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Neural Network	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Neural networks are used in self-driving cars to make decisions based on various inputs.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	t	f	1	general	advanced	2025-09-03 06:01:54.413
9be26dfd-9889-4af0-83ba-da4abc3686c1	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Natural Language Processing (NLP)	The ability of a computer program to understand human language as it is spoken.	Google Translate uses natural language processing to translate sentences into different languages.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:01:54.413
54cd5c73-9d6a-4cb6-8031-9e699e126a66	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Deep Learning	In machine learning, deep learning focuses on utilizing multilayered neural networks to perform tasks such as classification, regression, and representation learning. The field takes inspiration from ...	Deep learning is used in voice recognition systems like Amazon's Alexa.	Wikipedia	https://en.wikipedia.org/wiki/Deep_learning	t	f	1	general	advanced	2025-09-03 06:01:54.413
2700320a-e57f-4753-97dd-e7226373d68f	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Reinforcement Learning	Reinforcement learning (RL) is an interdisciplinary area of machine learning and optimal control concerned with how an intelligent agent should take actions in a dynamic environment in order to maximi...	Reinforcement learning is used in training AI for video games to make optimal moves.	Wikipedia	https://en.wikipedia.org/wiki/Reinforcement_learning	t	f	1	general	advanced	2025-09-03 06:01:54.413
9825617c-fdd9-4259-b79a-a8cee88568cf	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Supervised Learning	A type of machine learning where the model is trained on labeled data.	In supervised learning, an email spam filter is trained with many example emails with their labels (spam or not spam).	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:01:54.413
5f21829a-4eda-403d-93bf-37603717aea6	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Unsupervised Learning	A type of machine learning algorithm used to draw inferences from datasets consisting of input data without labeled responses.	Unsupervised learning can be used to identify clusters of customers based on their purchasing behavior.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:01:54.413
bb22449a-c702-4a39-8334-5358668e9d53	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Algorithm	In mathematics and computer science, an algorithm is a finite sequence of mathematically rigorous instructions, typically used to solve a class of specific problems or to perform a computation. Algori...	Search engines use complex algorithms to retrieve and prioritize results.	Wikipedia	https://en.wikipedia.org/wiki/Algorithm	t	f	1	general	advanced	2025-09-03 06:01:54.413
99f19923-44e2-4319-a200-73e719ceb50a	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Data Mining	Data mining is the process of extracting and finding patterns in massive data sets involving methods at the intersection of machine learning, statistics, and database systems. Data mining is an interd...	Companies use data mining techniques to analyze customer data and develop targeted marketing strategies.	Wikipedia	https://en.wikipedia.org/wiki/Data_mining	t	f	1	technique	advanced	2025-09-03 06:01:54.413
dfc2ceaa-9115-473e-abae-424c96c89923	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Robotics	Robotics is the interdisciplinary study and practice of the design, construction, operation, and use of robots....	Artificial intelligence is a crucial aspect of advanced robotics, allowing robots to interpret and respond to the world around them.	Wikipedia	https://en.wikipedia.org/wiki/Robotics	t	f	1	general	intermediate	2025-09-03 06:01:54.413
042610bf-6f9f-4268-9662-3e6de7fc3537	cc553f3c-f717-44cc-af15-56baba255b3c	\N	HTML	Hypertext Markup Language (HTML) is the standard markup language for documents designed to be displayed in a web browser. It defines the content and structure of web content. It is often assisted by t...	HTML elements are the building blocks of HTML pages.	Wikipedia	https://en.wikipedia.org/wiki/HTML	t	f	1	general	advanced	2025-09-03 06:04:52.37
79d5d5b6-5da4-4aa3-8694-4bdc7a0c7c72	cc553f3c-f717-44cc-af15-56baba255b3c	\N	CSS	Cascading Style Sheets (CSS) is a style sheet language used for specifying the presentation and styling of a document written in a markup language such as HTML or XML. CSS is a cornerstone technology ...	CSS is used to define styles for your web pages, including the design, layout and variations in display for different devices and screen sizes.	Wikipedia	https://en.wikipedia.org/wiki/CSS	t	f	1	general	advanced	2025-09-03 06:04:52.37
89d1982b-fbfe-408e-80ca-a07e06d19365	cc553f3c-f717-44cc-af15-56baba255b3c	\N	JavaScript	JavaScript (JS) is a programming language and core technology of the web platform, alongside HTML and CSS. Ninety-nine percent of websites on the World Wide Web use JavaScript on the client side for w...	JavaScript can update and change both HTML and CSS.	Wikipedia	https://en.wikipedia.org/wiki/JavaScript	t	f	1	general	advanced	2025-09-03 06:04:52.37
0c736f20-9aa6-48e6-9fc3-0faa1cd8af10	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Front-End	The client side of a web application, usually involving HTML, CSS, and JavaScript.	Front-end developers are responsible for the look and feel of a website.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:04:52.37
c6086d39-0f2d-4279-9420-955b564f9760	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Back-End	The server-side of a web application, responsible for managing data within the database and serving that data to the front-end to be displayed.	Back-end developers usually write the web services and APIs used by front-end developers and mobile application developers.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 06:04:52.37
136e86ce-5584-4677-8f46-cf9cab626ae3	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Responsive Web Design	Responsive web design (RWD) or responsive design is an approach to web design that aims to make web pages render well on a variety of devices and window or screen sizes from minimum to maximum display...	With responsive web design, your website will adjust to the screen size and orientation of the device it's being viewed on.	Wikipedia	https://en.wikipedia.org/wiki/Responsive_web_design	t	f	1	general	advanced	2025-09-03 06:04:52.37
d7b41349-5f58-491d-b97b-2abb1d3c0641	cc553f3c-f717-44cc-af15-56baba255b3c	\N	API	An application programming interface (API) is a connection between computers or between computer programs. It is a type of software interface, offering a service to other pieces of software. A documen...	Twitter's API allows developers to access and integrate Twitter's functionality into their own software or application.	Wikipedia	https://en.wikipedia.org/wiki/API	t	f	1	tool	advanced	2025-09-03 06:04:52.37
31416268-3d91-43eb-a7fe-1c6eba1935b4	cc553f3c-f717-44cc-af15-56baba255b3c	\N	MySQL	MySQL is an open-source relational database management system (RDBMS). Its name is a combination of "My", the name of co-founder Michael Widenius's daughter My, and "SQL", the acronym for Structured Q...	MySQL is widely used for web-based applications, online publishing and web development.	Wikipedia	https://en.wikipedia.org/wiki/MySQL	t	f	1	general	advanced	2025-09-03 06:04:52.37
be02516f-57c3-4241-abdc-3f6b6d518c04	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Bootstrap	Bootstrapping is a self-starting process that is supposed to proceed without external input....	Bootstrap provides ready-made design templates for web developers.	Wikipedia	https://en.wikipedia.org/wiki/Bootstrapping_(disambiguation)	t	f	1	general	beginner	2025-09-03 06:04:52.37
581a0eb7-b997-4214-b803-6ec23a3f30f2	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Git	Git is a distributed version control software system that is capable of managing versions of source code or data. It is often used to control source code by programmers who are developing software col...	Git is used to manage various versions of a project, allowing multiple developers to work together on the same project without overwriting each other's changes.	Wikipedia	https://en.wikipedia.org/wiki/Git	t	f	1	tool	advanced	2025-09-03 06:04:52.37
254d234b-28e9-456f-b603-944df6d7c1fa	cc553f3c-f717-44cc-af15-56baba255b3c	\N	AJAX	Ajax is a set of web development techniques that uses various web technologies on the client-side to create asynchronous web applications. With Ajax, web applications can send and retrieve data from a...	With AJAX, web applications can send and retrieve data from a server asynchronously without interfering with the display and behavior of the existing page.	Wikipedia	https://en.wikipedia.org/wiki/Ajax_(programming)	t	f	1	general	advanced	2025-09-03 06:04:52.37
3f84f8f5-b0c0-47e4-a6a5-8c878e923ec2	6a141c53-2608-427e-b3a4-64957e874a60	\N	Big Data	Big data primarily refers to data sets that are too large or complex to be dealt with by traditional data-processing software. Data with many entries (rows) offer greater statistical power, while data...	In data science, big data is often used to predict buying patterns of customers.	Wikipedia	https://en.wikipedia.org/wiki/Big_data	t	f	1	tool	advanced	2025-09-03 06:07:30.461
c2572c61-7df5-4377-8298-5c4835659265	6a141c53-2608-427e-b3a4-64957e874a60	\N	Machine Learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	In data science, machine learning algorithms can be used to predict future trends based on past data.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	t	f	1	general	advanced	2025-09-03 06:07:30.461
538566c6-42a4-4456-83d5-a3a9c65363e1	6a141c53-2608-427e-b3a4-64957e874a60	\N	Data Mining	Data mining is the process of extracting and finding patterns in massive data sets involving methods at the intersection of machine learning, statistics, and database systems. Data mining is an interd...	Data mining techniques are used in data science to extract useful information from large datasets.	Wikipedia	https://en.wikipedia.org/wiki/Data_mining	t	f	1	technique	advanced	2025-09-03 06:07:30.461
22101650-d25d-4802-b0a8-d8d0180a70f5	6a141c53-2608-427e-b3a4-64957e874a60	\N	Predictive Analytics	Predictive analytics encompasses a variety of statistical techniques from data mining, predictive modeling, and machine learning that analyze current and historical facts to make predictions about fut...	Data science uses predictive analytics to forecast customer behavior, equipment failures, and other future events.	Wikipedia	https://en.wikipedia.org/wiki/Predictive_analytics	t	f	1	general	advanced	2025-09-03 06:07:30.461
84e3860b-f766-4de7-ac46-208dc7706d7b	6a141c53-2608-427e-b3a4-64957e874a60	\N	Data Visualization	Data and information visualization is the practice of designing and creating graphic or visual representations of quantitative and qualitative data and information with the help of static, dynamic or ...	In data science, data visualization is used to show patterns, trends, and correlations that might go unnoticed in text-based data.	Wikipedia	https://en.wikipedia.org/wiki/Data_and_information_visualization	t	f	1	general	advanced	2025-09-03 06:07:30.461
4895709f-e16d-4c8f-8a58-a817d2ce1230	6a141c53-2608-427e-b3a4-64957e874a60	\N	Data Cleaning	Data cleansing or data cleaning is the process of identifying and correcting corrupt, inaccurate, or irrelevant records from a dataset, table, or database. It involves detecting incomplete, incorrect,...	Data cleaning is a crucial step in data science to ensure the accuracy of the results.	Wikipedia	https://en.wikipedia.org/wiki/Data_cleansing	t	f	1	general	advanced	2025-09-03 06:07:30.461
fdd0fd3d-ae41-4912-bfa6-beb4023fd300	6a141c53-2608-427e-b3a4-64957e874a60	\N	Algorithm	In mathematics and computer science, an algorithm is a finite sequence of mathematically rigorous instructions, typically used to solve a class of specific problems or to perform a computation. Algori...	Data scientists use algorithms to analyze data, make predictions, and make decisions.	Wikipedia	https://en.wikipedia.org/wiki/Algorithm	t	f	1	general	advanced	2025-09-03 06:07:30.461
f82651c7-a7de-41f0-b18e-b648dad7f6da	6a141c53-2608-427e-b3a4-64957e874a60	\N	Regression	Regression or regressions may refer to:...	In data science, regression might be used to understand the impact of age, income, and diet (independent variables) on the likelihood of getting a certain disease (dependent variable).	Wikipedia	https://en.wikipedia.org/wiki/Regression	t	f	1	general	beginner	2025-09-03 06:07:30.461
75c3ceae-2de8-4b1a-984b-165cdec51920	6a141c53-2608-427e-b3a4-64957e874a60	\N	Classification	Classification is the activity of assigning objects to some pre-existing classes or categories. This is distinct from the task of establishing the classes themselves. Examples include diagnostic tests...	In data science, classification algorithms are used to predict or categorize discrete responses.	Wikipedia	https://en.wikipedia.org/wiki/Classification	t	f	1	general	advanced	2025-09-03 06:07:30.461
85b925a2-285c-4931-bd61-d9f1104c51fe	6a141c53-2608-427e-b3a4-64957e874a60	\N	Anomaly Detection	The identification of rare items, events or observations which raise suspicions by differing significantly from the majority of the data.	In data science, anomaly detection can be used for fraud detection or system health monitoring.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:07:30.461
de217bc1-cd25-4ccf-89e6-9ace1cc18a04	6a141c53-2608-427e-b3a4-64957e874a60	\N	Neural Networks	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	In data science, neural networks are used for tasks such as image recognition and speech recognition.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	t	f	1	general	advanced	2025-09-03 06:07:30.461
27ccf93f-49a6-4b7f-acc9-efff99028f32	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Quota	A predetermined limit set for the number of tests that can be administered within a certain time period or by a particular entity.	The university has a test quota of 500 exams per semester.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 06:50:45.3
f3913375-fd87-499d-a25a-453abdf0a640	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Allocation	The process of distributing tests among different entities or individuals.	Test allocation is a crucial part of managing a test quota.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:50:45.3
c7045baf-3293-49c1-91c7-2965f8fe344a	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Limit	The maximum number of tests that can be conducted within a specific period.	The test limit for this module is three per semester.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:50:45.3
8cc465e1-a1e9-495e-9aaa-619ac0f376dc	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Management	Test management most commonly refers to the activity of managing a testing process. A test management tool is software used to manage tests that have been previously specified by a test procedure. It ...	Effective test management is crucial for maintaining academic integrity.	Wikipedia	https://en.wikipedia.org/wiki/Test_management	t	f	1	tool	advanced	2025-09-03 06:50:45.3
0dc6ab64-26e6-4e92-a030-efeccec3556d	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Schedule	A timetable outlining when specific tests will be administered.	The test schedule helps students prepare in advance for their exams.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:50:45.3
4e25038a-bfee-450d-9f1c-81f4f1a118a3	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Capacity	The total number of tests that can be conducted by a system or facility at any given time.	The test capacity of the lab is 200 tests per day.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:50:45.3
d55eac64-39ee-4ac9-b8ab-d2323fe8686b	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Frequency	The regularity with which tests are administered.	The test frequency in this program is once every two weeks.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:50:45.3
5693c0bb-cef0-417c-9d27-2697fb6d5509	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Overload	A situation where the number of tests exceeds the test quota or capacity.	A test overload can lead to system inefficiencies and errors.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:50:45.3
9e9e7c49-b5ee-47d0-a1e2-a796c9f6e261	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Backlog	The number of tests that are pending or yet to be conducted.	The test backlog increased due to the unavailability of test personnel.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:50:45.3
d8afafe7-6fa7-458b-a5c4-ac8069cbb54b	e16ddde0-0620-440d-99d1-99c9c86fc8d9	\N	Test Window	The defined period during which a test can be taken.	The test window for the final exam is from 9 AM to 5 PM.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:50:45.3
10832463-cf5c-4d28-81cf-ef968a4c015f	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Quota	Quota may refer to:...	The country has no quotas for employment.	Wikipedia	https://en.wikipedia.org/wiki/Quota	t	f	1	general	beginner	2025-09-03 06:51:22.334
8f6bdf24-22dd-4e74-9ac9-9b12d8644f09	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Case	Test case may refer to:Test case (law), a case brought to set a legal precedent\nTest case (software), a set of conditions and variables used to test a software application\n"The Test Case", a 1915 shor...	The test case for the new software was successful.	Wikipedia	https://en.wikipedia.org/wiki/Test_case	t	f	1	tool	advanced	2025-09-03 06:51:22.334
4859e49a-3b5c-4d71-ab4d-72d99a78d584	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Load Testing	A type of performance testing that determines a system's behavior under both normal and anticipated peak load conditions.	Load testing was utilized to evaluate how the software performed under heavy usage.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:51:22.334
5fe1c6ca-4f33-4a77-9abf-e7942b1537f4	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Coverage	A measure used in software testing that describes the degree to which the source code of a program is tested.	The team sought to achieve high test coverage to ensure all code was effective.	AI Generated	\N	f	t	0.8	tool	intermediate	2025-09-03 06:51:22.334
432ffd85-73e4-459b-ab8d-b8839c9dd686	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Scenario	A description of an objective a user might face when using the program.	The team created multiple test scenarios for the new app.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:51:22.334
73bf938b-24c2-4dec-8230-dc81b2107391	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Suite	\nIn software development, a test suite, less commonly known as a validation suite, is a collection of test cases that are intended to be used to test a software program to show that it has some specif...	The test suite was run to check the new software version's functionality.	Wikipedia	https://en.wikipedia.org/wiki/Test_suite	t	f	1	tool	advanced	2025-09-03 06:51:22.334
1193c5e4-6873-446a-a260-0e631addbd4c	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Regression Testing	Regression testing is re-running functional and non-functional tests to ensure that previously developed and tested software still performs as expected after a change. If not, that would be called a r...	Regression testing was done after the update to ensure all features were still operational.	Wikipedia	https://en.wikipedia.org/wiki/Regression_testing	t	f	1	tool	advanced	2025-09-03 06:51:22.334
6833854a-a7cb-4dbe-8527-c46882d5f7ff	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Environment	A setup of software and hardware on which the testing team will execute test cases.	In the test environment, we found the software's performance to be satisfactory.	AI Generated	\N	f	t	0.8	tool	beginner	2025-09-03 06:51:22.334
fde4a694-da92-4aef-a972-51f6146736d6	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Data	Test data are sets of inputs or information used to verify the correctness, performance, and reliability of software systems. Test data encompass various types, such as positive and negative scenarios...	The test data showed that the system was functioning as expected.	Wikipedia	https://en.wikipedia.org/wiki/Test_data	t	f	1	tool	advanced	2025-09-03 06:51:22.334
4a78b02f-319f-4bfd-905e-19dc9952d167	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Plan	A test plan is a document detailing the objectives, resources, and processes for a specific test session for a software or hardware product. The plan typically contains a detailed understanding of the...	The test plan outlined how the testing process would be conducted.	Wikipedia	https://en.wikipedia.org/wiki/Test_plan	t	f	1	tool	advanced	2025-09-03 06:51:22.334
633f7545-1cb2-4b88-a7de-28705c445f0f	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	\N	Test Strategy	A test strategy is an outline that describes the testing approach of the software development cycle. The purpose of a test strategy is to provide a rational deduction from organizational, high-level o...	The test strategy was focused on user experience and functionality.	Wikipedia	https://en.wikipedia.org/wiki/Test_strategy	t	f	1	tool	advanced	2025-09-03 06:51:22.334
8fc6ecc2-0b00-4cf0-8503-1791b6253cbc	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Quota	A limit set on the number of tests which an individual or a system can run within a particular time period.	The company set a test quota of 100 tests per week for its QA team.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 06:52:15.432
1b7a6e03-4dfd-4f6b-a9c2-644caa130372	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Load Testing	A type of performance testing that checks how a system operates under a heavy load.	The QA team performed load testing to check if the system can handle the test quota.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:52:15.432
c4192eff-8641-4d92-b928-ed3b338d8595	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Performance Testing	Performance test or performance testing may refer to:Performance test (assessment), an assessment requiring the subject to perform a task or activity\nPerformance test, a section of the bar exam simula...	Performance testing was done to ensure the system can handle the test quota.	Wikipedia	https://en.wikipedia.org/wiki/Performance_testing	t	f	1	general	advanced	2025-09-03 06:52:15.432
a437d627-ba47-4741-b309-7aa366c04f9d	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Stress Testing	A type of testing that checks the robustness of software by testing beyond the limits of normal operation.	Stress testing was done to see if the system can exceed the test quota.	AI Generated	\N	f	t	0.8	tool	intermediate	2025-09-03 06:52:15.432
4dc14080-1076-40e8-8af0-15e6f29efea1	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Case	Test case may refer to:Test case (law), a case brought to set a legal precedent\nTest case (software), a set of conditions and variables used to test a software application\n"The Test Case", a 1915 shor...	The tester created a test case to verify if the test quota was being adhered to.	Wikipedia	https://en.wikipedia.org/wiki/Test_case	t	f	1	tool	advanced	2025-09-03 06:52:15.432
02e33753-ed33-436b-a587-34714c7afd99	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Suite	\nIn software development, a test suite, less commonly known as a validation suite, is a collection of test cases that are intended to be used to test a software program to show that it has some specif...	The test suite was run to check if the system adheres to the test quota.	Wikipedia	https://en.wikipedia.org/wiki/Test_suite	t	f	1	tool	advanced	2025-09-03 06:52:15.432
3470fef0-0990-479e-ae98-be219e8dd3cd	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Plan	A test plan is a document detailing the objectives, resources, and processes for a specific test session for a software or hardware product. The plan typically contains a detailed understanding of the...	The test plan included a test quota for each tester.	Wikipedia	https://en.wikipedia.org/wiki/Test_plan	t	f	1	tool	advanced	2025-09-03 06:52:15.432
93883c24-cf25-480f-9a43-89d4d492629f	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Scenario	An approach to testing where different variables that can affect the outcome are identified and changed one after the other to see what the outcome is.	Test scenarios were used to check if the system can handle exceeding the test quota.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 06:52:15.432
ed6b0f2a-b9b9-45da-ae3f-4201a7583cdd	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Script	A set of instructions that is performed on a system under test to verify that the system performs as expected.	A test script was written to validate the test quota functionality.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:52:15.432
f3c0dc60-9f43-41b0-815a-9c9af4faeb6f	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	\N	Test Automation	Test automation is the use of software for controlling the execution of tests and comparing actual outcome with predicted. Test automation supports testing the system under test (SUT) without manual i...	Test automation was used to quickly run through the test quota.	Wikipedia	https://en.wikipedia.org/wiki/Test_automation	t	f	1	tool	advanced	2025-09-03 06:52:15.432
29cacd61-4e2a-4af9-b57b-36534ca7e4a9	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Front-End Development	The practice of creating HTML, CSS and JavaScript for a website or Web Application so that a user can see and interact with them directly.	The design and layout of this website is a product of front-end development.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:05:10.955
8f962ec3-d82d-4bfe-9d5f-f1abc2da6a22	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Back-End Development	The server-side of web development focused on how the site works, updates and changes. This refers to everything the user can't see in the browser, like databases and servers.	The database that stores user data is part of back-end development.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:05:10.955
4b9da7fd-4fce-4627-ac97-1f5c310e30e4	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Responsive Design	A web design approach that makes web pages render well on a variety of devices and window or screen sizes.	This website's responsive design makes it easily viewable on both desktop and mobile devices.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:05:10.955
88dbef75-8db5-46d4-99b8-7bd2018f54bc	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	API	An application programming interface (API) is a connection between computers or between computer programs. It is a type of software interface, offering a service to other pieces of software. A documen...	The weather app on your phone uses an API to pull weather data from a server.	Wikipedia	https://en.wikipedia.org/wiki/API	t	f	1	tool	advanced	2025-09-03 16:05:10.955
150590d5-2b07-4668-a55b-5e50999195ea	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	CSS	Cascading Style Sheets (CSS) is a style sheet language used for specifying the presentation and styling of a document written in a markup language such as HTML or XML. CSS is a cornerstone technology ...	The website's colors and fonts are styled using CSS.	Wikipedia	https://en.wikipedia.org/wiki/CSS	t	f	1	general	advanced	2025-09-03 16:05:10.955
a6aa8917-f017-4383-a63b-cec6b924823d	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	HTML	Hypertext Markup Language (HTML) is the standard markup language for documents designed to be displayed in a web browser. It defines the content and structure of web content. It is often assisted by t...	The structure of this webpage is created using HTML.	Wikipedia	https://en.wikipedia.org/wiki/HTML	t	f	1	general	advanced	2025-09-03 16:05:10.955
f779382e-b9d0-4797-9284-534ea9e0ece3	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	JavaScript	JavaScript (JS) is a programming language and core technology of the web platform, alongside HTML and CSS. Ninety-nine percent of websites on the World Wide Web use JavaScript on the client side for w...	The interactive elements of this webpage are created using JavaScript.	Wikipedia	https://en.wikipedia.org/wiki/JavaScript	t	f	1	general	advanced	2025-09-03 16:05:10.955
08800462-a0be-4310-9c8e-e35c35125a33	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	AJAX	Ajax is a set of web development techniques that uses various web technologies on the client-side to create asynchronous web applications. With Ajax, web applications can send and retrieve data from a...	The website uses AJAX to load new content without refreshing the page.	Wikipedia	https://en.wikipedia.org/wiki/Ajax_(programming)	t	f	1	general	advanced	2025-09-03 16:05:10.955
1dee5117-58ea-4e7f-bd04-09ec61d0a539	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Bootstrap	Bootstrapping is a self-starting process that is supposed to proceed without external input....	The developer used Bootstrap to quickly create a responsive design for the website.	Wikipedia	https://en.wikipedia.org/wiki/Bootstrapping_(disambiguation)	t	f	1	general	beginner	2025-09-03 16:05:10.955
b0db1fb0-962d-470d-a78b-26803b45c708	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Full Stack Development	The development of both front end (client side) and back end (server side) portions of web application.	Full stack development involves working on the HTML, CSS, and JavaScript of a site, as well as managing the server and database.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:05:10.955
e88c3845-1ff6-43b1-ac8b-6fa9bd4e191e	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Progressive Web App (PWA)	A type of application software delivered through the web, built using common web technologies including HTML, CSS and JavaScript. It is intended to work on any platform that uses a standards-compliant browser.	The website also functions as a Progressive Web App, allowing users to install it on their devices for offline use.	AI Generated	\N	f	t	0.8	tool	advanced	2025-09-03 16:05:10.955
32555941-40e0-435f-82b2-612dfb157b15	8f37e7c1-b91a-4745-918b-1f1567778e5b	\N	Content Management System (CMS)	A software application or set of related programs that are used to create and manage digital content.	WordPress is a popular Content Management System used to build websites.	AI Generated	\N	f	t	0.8	tool	intermediate	2025-09-03 16:05:10.955
2eacd7d4-b966-4d84-ab75-ed292b6695b9	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Enterprise	Enterprise may refer to:...	Microsoft is a global enterprise with operations in over 100 countries.	Wikipedia	https://en.wikipedia.org/wiki/Enterprise	t	f	1	general	beginner	2025-09-03 16:20:47.338
ea5c1fd3-9edf-417f-a8f1-14408c33b965	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Entrepreneur	Entrepreneurship is the creation or extraction of economic value in ways that generally entail beyond the minimal amount of risk, and potentially involving values besides simply economic ones....	Elon Musk is a well-known entrepreneur with multiple successful enterprises under his belt.	Wikipedia	https://en.wikipedia.org/wiki/Entrepreneurship	t	f	1	general	advanced	2025-09-03 16:20:47.338
dfa8ef50-4d2b-40b0-8d06-4077045fcece	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Business Model	A business model describes how a business organization creates, delivers, and captures value, in economic, social, cultural or other contexts. The model describes the specific way in which the busines...	Uber's business model relies on the gig economy and mobile technology.	Wikipedia	https://en.wikipedia.org/wiki/Business_model	t	f	1	general	advanced	2025-09-03 16:20:47.338
9a79fff8-0e2e-4ad6-9603-2fd00571f8db	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Stakeholder	Stakeholder may refer to:Stakeholder (corporate), a group, corporate, organization, member, or system that affects or can be affected by an organization's actions\nProject stakeholder, a person, group,...	Employees, customers, and investors are all stakeholders in a company.	Wikipedia	https://en.wikipedia.org/wiki/Stakeholder	t	f	1	general	advanced	2025-09-03 16:20:47.338
6b605c7c-2dbb-414a-b0e2-7c7c2b5ada28	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Supply Chain	A supply chain is a complex logistics system that consists of facilities that convert raw materials into finished products and distribute them to end consumers or end customers, while supply chain man...	Global enterprises often have complex supply chains that stretch across multiple countries.	Wikipedia	https://en.wikipedia.org/wiki/Supply_chain	t	f	1	general	advanced	2025-09-03 16:20:47.338
a84dff73-8359-46bb-9215-0f5f3433c2e4	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Revenue	In accounting, revenue is the total amount of income generated by the sale of goods and services related to the primary operations of a business.\nCommercial revenue may also be referred to as sales or...	The company's annual revenue exceeded one billion dollars this year.	Wikipedia	https://en.wikipedia.org/wiki/Revenue	t	f	1	general	advanced	2025-09-03 16:20:47.338
0db6fb39-bae1-46e6-81b8-0a9e488a2330	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Profit Margin	Profit margin is a financial ratio that measures the percentage of profit earned by a company in relation to its revenue. Expressed as a percentage, it indicates how much profit the company makes for ...	High profit margins indicate a very profitable enterprise.	Wikipedia	https://en.wikipedia.org/wiki/Profit_margin	t	f	1	general	advanced	2025-09-03 16:20:47.338
2c4028f0-9b84-43f3-93d3-002b6d1a1d66	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Market Share	The portion of a market controlled by a particular company or product.	With its latest product, the company aims to increase its market share in the smartphone industry.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 16:20:47.338
195600c0-556b-43ce-b65f-f7c6c124cdba	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Competitive Advantage	In business, a competitive advantage is an attribute that allows an organization to outperform its competitors....	Innovative technology can give an enterprise a competitive advantage.	Wikipedia	https://en.wikipedia.org/wiki/Competitive_advantage	t	f	1	general	intermediate	2025-09-03 16:20:47.338
511d9945-f6e0-4169-a81f-1ef342832439	0a13eaab-9475-4f95-be1f-03aa033fbe56	\N	Corporate Culture	Organizational culture encompasses the shared norms, values, and behaviors—observed in schools, not-for-profit groups, government agencies, sports teams, and businesses—reflecting their core values an...	Google is known for its open and innovative corporate culture.	Wikipedia	https://en.wikipedia.org/wiki/Organizational_culture	t	f	1	general	advanced	2025-09-03 16:20:47.338
b8c6f3a6-fc20-4a68-bd67-e62e3f9bc8b3	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Resource Planning (ERP)	A system used by businesses to manage day-to-day business activities such as accounting, procurement, project management, risk management and compliance, and supply chain operations.	SAP and Oracle are well-known ERP software providers.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:20:58.548
85642102-87f6-47cf-abf5-64f345d1393e	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Supply Chain Management (SCM)	The management of the flow of goods and services, involving the movement and storage of raw materials, of work-in-process inventory, and of finished goods as well as end to end order fulfillment from point of origin to point of consumption.	Walmart's efficient SCM system is one of the reasons for its success in the retail industry.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:20:58.548
462a09c3-0571-4dca-8abf-01dc8ccf0c5f	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Customer Relationship Management (CRM)	Customer relationship management (CRM) is a strategic process that organizations use to manage, analyze, and improve their interactions with customers. By leveraging data-driven insights, CRM helps bu...	Salesforce is a popular CRM software used by many businesses.	Wikipedia	https://en.wikipedia.org/wiki/Customer_relationship_management	t	f	1	general	advanced	2025-09-03 16:20:58.548
125beadb-7054-45a1-a8d3-d27c3500fd6d	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Business Intelligence (BI)	Technologies, applications and practices for the collection, integration, analysis, and presentation of business information to support better business decision making.	Tableau is a BI tool that helps companies visualize their data.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:20:58.548
4efe3d62-d183-45da-86cc-248083f9cadd	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Content Management (ECM)	A system solution designed to manage an organization's documents. It involves the capture, storage, preservation, and delivery of content and documents related to organizational processes.	Microsoft SharePoint is an example of an ECM system.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:20:58.548
4ed8279c-b7f0-49b3-94f8-ec500adcbd86	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Architecture (EA)	A conceptual blueprint that defines the structure and operation of an organization with the intent to determine how an organization can most effectively achieve its current and future objectives.	EA helps businesses by providing a strategic context for the evolution of the IT system in response to the constantly changing needs of business environment.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:20:58.548
50380dc7-279f-47e6-bd35-7bdbfa87e189	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Data Management (EDM)	An organization's ability to effectively create, integrate, disseminate and manage data for all enterprise processes, entities, properties and applications.	EDM helps in maintaining data accuracy, consistency and security across the organization.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:20:58.548
105bda64-f179-4786-8702-3fd03eca53fb	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Performance Management (EPM)	The process of monitoring performance across the enterprise with the goal of improving business performance.	EPM involves consolidation of data from various sources, querying, and analysis of the data, and putting the results into practice.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:20:58.548
3f409007-8cd1-489a-ae11-ed23d9dd0781	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Risk Management (ERM)	A process, effected by an entity's board of directors, management and other personnel, applied in strategy setting and across the enterprise, designed to identify potential events that may affect the entity, and manage risk to be within its risk appetite, to provide reasonable assurance regarding the achievement of entity objectives.	Companies often use ERM as a tool to identify and minimize risks across various departments.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:20:58.548
fb6f0155-c6b8-46e3-8b42-9629bbffd104	97a012d4-c329-4809-bd5f-70e7e5c812fc	\N	Enterprise Software	Enterprise software, also known as enterprise application software (EAS), is computer software that has been specially developed or adapted to meet the complex requirements of larger organizations. En...	Microsoft Office Suite is a type of enterprise software used in most businesses.	Wikipedia	https://en.wikipedia.org/wiki/Enterprise_software	t	f	1	tool	advanced	2025-09-03 16:20:58.548
9fa6c060-ba15-4b63-8b38-50bfa27d6514	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Enterprise Resource Planning (ERP)	A business process management software that allows an organization to use a system of integrated applications to manage the business and automate many back office functions related to technology, services and human resources.	SAP and Oracle are two widely used Enterprise Resource Planning systems.	AI Generated	\N	f	t	0.8	tool	advanced	2025-09-03 16:21:12.596
4f3bec4d-16be-4919-867a-7aeae5d47cde	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Customer Relationship Management (CRM)	Customer relationship management (CRM) is a strategic process that organizations use to manage, analyze, and improve their interactions with customers. By leveraging data-driven insights, CRM helps bu...	Salesforce is a popular Customer Relationship Management software.	Wikipedia	https://en.wikipedia.org/wiki/Customer_relationship_management	t	f	1	general	advanced	2025-09-03 16:21:12.596
e82f6e71-ad07-4524-9dfb-027f9a1e1f22	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Supply Chain Management (SCM)	The active management of supply chain activities to maximize customer value and achieve a sustainable competitive advantage.	Walmart's efficient supply chain management strategy is one of the reasons for its success.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
57e887bd-3c19-424f-96d9-f9088a0cdb0f	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Business Intelligence (BI)	Technologies, applications and practices for the collection, integration, analysis, and presentation of business information.	Tableau is a powerful Business Intelligence tool used for data visualization.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
f8f642c6-aa20-4941-ae90-6e723498c13e	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Business Process Reengineering (BPR)	The practice of rethinking and redesigning the way work is done to better support an organization's mission and reduce costs.	Companies often undertake Business Process Reengineering to become more efficient and modernize their operations.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
d847f8c4-faf6-4d22-bc4f-ea322a5e42e5	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Change Management	Change management (CM) is a discipline that focuses on managing changes within an organization. Change management involves implementing approaches to prepare and support individuals, teams, and leader...	Change management is critical when implementing a new ERP system in a company.	Wikipedia	https://en.wikipedia.org/wiki/Change_management	t	f	1	general	advanced	2025-09-03 16:21:12.596
86cadbdc-3f6a-46d7-9803-88b193082541	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Business Continuity Planning (BCP)	The process of creating systems of prevention and recovery to deal with potential threats to a company.	Business Continuity Planning is vital to ensure a company can continue operations during a crisis or disaster.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
1493ccd4-f730-4be0-824a-039d0ba649dd	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Data Warehousing	In computing, a data warehouse, also known as an enterprise data warehouse (EDW), is a system used for reporting and data analysis and is a core component of business intelligence. Data warehouses are...	Data warehousing is usually the first step in any data analysis process.	Wikipedia	https://en.wikipedia.org/wiki/Data_warehouse	t	f	1	general	advanced	2025-09-03 16:21:12.596
9a970c9e-235e-4fad-bfd7-b7584a128b92	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Key Performance Indicator (KPI)	A set of quantifiable measures that a company uses to gauge its performance over time.	Sales growth is a common Key Performance Indicator for businesses.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 16:21:12.596
c13221c9-1ae9-4488-96d7-800002d26c05	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Software as a Service (SaaS)	A software licensing and delivery model in which software is licensed on a subscription basis and is centrally hosted.	Google Docs is an example of Software as a Service.	AI Generated	\N	f	t	0.8	tool	intermediate	2025-09-03 16:21:12.596
b046a7cf-32dd-4e96-a8f5-3599c5190cbc	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Business-to-Business (B2B)	A form of transaction between businesses, such as one involving a manufacturer and wholesaler, or a wholesaler and a retailer.	Adobe offers B2B products to other businesses, such as its Creative Cloud suite of applications.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
5f993f8d-85d2-4082-a2e1-59984c26e4ed	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Business-to-Consumer (B2C)	Business or transactions conducted directly between a company and consumers who are the end-users of its products or services.	Amazon is a prime example of a Business-to-Consumer company.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
38aa5ff8-21cd-401d-8858-dfe58daef098	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Cloud Computing	Cloud computing is "a paradigm for enabling network access to a scalable and elastic pool of shareable physical or virtual resources with self-service provisioning and administration on-demand," accor...	Google Drive is a popular cloud computing service.	Wikipedia	https://en.wikipedia.org/wiki/Cloud_computing	t	f	1	general	advanced	2025-09-03 16:21:12.596
1782f690-3ec4-4eac-b01e-1247d616e4f5	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	E-commerce	E-commerce refers to commercial activities including the electronic buying or selling products and services which are conducted on online platforms or over the Internet. E-commerce draws on technologi...	Ebay and Amazon are well-known e-commerce platforms.	Wikipedia	https://en.wikipedia.org/wiki/E-commerce	t	f	1	general	advanced	2025-09-03 16:21:12.596
f8972d72-2466-440b-a085-8797941d8f4e	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	\N	Mobile Commerce (M-commerce)	The buying and selling of goods and services through wireless handheld devices such as smartphones and tablets.	The Starbucks app is an example of mobile commerce.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:21:12.596
b4058f8d-c2ec-41a3-9733-72a5d5bb36c1	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Enterprise Resource Planning (ERP)	A system used by companies to manage and integrate the important parts of their businesses.	SAP and Oracle are popular Enterprise Resource Planning (ERP) systems used by many large corporations.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 16:22:04.826
67e27925-5db0-4a58-93e9-5be5ee14b358	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Customer Relationship Management (CRM)	Customer relationship management (CRM) is a strategic process that organizations use to manage, analyze, and improve their interactions with customers. By leveraging data-driven insights, CRM helps bu...	Salesforce is a leading Customer Relationship Management (CRM) software.	Wikipedia	https://en.wikipedia.org/wiki/Customer_relationship_management	t	f	1	general	advanced	2025-09-03 16:22:04.826
6d17e818-dc1a-4357-837f-6b10d601fbb9	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Supply Chain Management (SCM)	The management of the flow of goods and services, involving the movement and storage of raw materials, of work-in-process inventory, and of finished goods.	Effective Supply Chain Management (SCM) can reduce wastage and increase efficiency.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:22:04.826
5e5df33d-b003-42df-a0bd-8cb9cafc03a2	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Business Process Management (BPM)	A discipline in operations management that uses various methods to discover, model, analyze, measure, improve and optimize business processes.	Business Process Management (BPM) ensures that workflows are both effective and efficient.	AI Generated	\N	f	t	0.8	technique	intermediate	2025-09-03 16:22:04.826
3ee1a6b2-6517-4c1b-9cda-d1824baf5eb5	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Business Intelligence (BI)	Technologies, applications and practices for the collection, integration, analysis, and presentation of business information.	Business Intelligence (BI) tools can help organizations make more informed decisions.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:22:04.826
a4ebc60f-da98-4154-afbc-d07b1ac9be49	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Cloud Computing	Cloud computing is "a paradigm for enabling network access to a scalable and elastic pool of shareable physical or virtual resources with self-service provisioning and administration on-demand," accor...	Companies like Amazon and Microsoft offer cloud computing services.	Wikipedia	https://en.wikipedia.org/wiki/Cloud_computing	t	f	1	general	advanced	2025-09-03 16:22:04.826
bd538642-160b-428b-a0dc-a58a047c5596	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Software as a Service (SaaS)	A software licensing and delivery model in which software is licensed on a subscription basis and is centrally hosted.	Netflix is a popular example of Software as a Service (SaaS).	AI Generated	\N	f	t	0.8	tool	intermediate	2025-09-03 16:22:04.826
a4d293fe-04b6-48a1-abfc-089eef33cc59	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Big Data	Big data primarily refers to data sets that are too large or complex to be dealt with by traditional data-processing software. Data with many entries (rows) offer greater statistical power, while data...	Many businesses use big data to gain insights into their customer's behavior.	Wikipedia	https://en.wikipedia.org/wiki/Big_data	t	f	1	tool	advanced	2025-09-03 16:22:04.826
c0ea0883-c718-4017-b096-3421494773a7	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Artificial Intelligence (AI)	Artificial intelligence (AI) is the capability of computational systems to perform tasks typically associated with human intelligence, such as learning, reasoning, problem-solving, perception, and dec...	Siri and Alexa are examples of Artificial Intelligence (AI) in everyday use.	Wikipedia	https://en.wikipedia.org/wiki/Artificial_intelligence	t	f	1	general	advanced	2025-09-03 16:22:04.826
006d31df-835b-4d91-a53e-78af60208b52	07b81f70-6b02-4afe-94e6-6aa07a0f3203	\N	Digital Transformation	Digital transformation (DT) is the process of adoption and implementation of digital technology by an organization in order to create new or modify existing products, services and operations by the me...	Many companies are undergoing digital transformation to stay competitive in the market.	Wikipedia	https://en.wikipedia.org/wiki/Digital_transformation	t	f	1	general	advanced	2025-09-03 16:22:04.826
85400d73-02e4-435c-9e94-efdfdaf8b95b	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Enterprise Resource Planning (ERP)	A system used by businesses to manage and integrate the important parts of their businesses.	SAP and Oracle are popular ERP software that many large enterprises use to streamline their processes.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 16:22:17.827
51d582b9-11e1-450a-ba31-acefaf4902f7	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Customer Relationship Management (CRM)	Customer relationship management (CRM) is a strategic process that organizations use to manage, analyze, and improve their interactions with customers. By leveraging data-driven insights, CRM helps bu...	Salesforce is a widely-used CRM tool that helps enterprises manage their customer relationships more efficiently.	Wikipedia	https://en.wikipedia.org/wiki/Customer_relationship_management	t	f	1	general	advanced	2025-09-03 16:22:17.827
6c26789c-596c-439c-948b-b21a1698b5d0	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Supply Chain Management (SCM)	The active management of supply chain activities to maximize customer value and achieve a sustainable competitive advantage.	Walmart uses SCM to ensure that their shelves are always stocked with products.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:22:17.827
32634035-4c18-4506-8e29-89d58b66170b	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Business Intelligence (BI)	Technologies, applications and practices for the collection, integration, analysis, and presentation of business information.	Companies use BI tools like Tableau to visualize their data and make informed decisions.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 16:22:17.827
6c89a706-487d-4435-91e9-ef43d930260f	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Cloud Computing	Cloud computing is "a paradigm for enabling network access to a scalable and elastic pool of shareable physical or virtual resources with self-service provisioning and administration on-demand," accor...	Amazon Web Services (AWS) provides cloud computing services that businesses can use to scale and grow.	Wikipedia	https://en.wikipedia.org/wiki/Cloud_computing	t	f	1	general	advanced	2025-09-03 16:22:17.827
7a4d469f-43e4-4d65-a321-a61212e03a7d	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Big Data	Big data primarily refers to data sets that are too large or complex to be dealt with by traditional data-processing software. Data with many entries (rows) offer greater statistical power, while data...	Social media platforms like Facebook use big data to analyze user behavior and target ads more effectively.	Wikipedia	https://en.wikipedia.org/wiki/Big_data	t	f	1	tool	advanced	2025-09-03 16:22:17.827
9d3bc0ca-ca47-4f5f-8c32-dd7837a25f43	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Artificial Intelligence (AI)	Artificial intelligence (AI) is the capability of computational systems to perform tasks typically associated with human intelligence, such as learning, reasoning, problem-solving, perception, and dec...	Google uses AI to improve search results and ad relevancy.	Wikipedia	https://en.wikipedia.org/wiki/Artificial_intelligence	t	f	1	general	advanced	2025-09-03 16:22:17.827
0a2e442a-4261-48d6-a146-05e4d70bd6e1	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Information Technology (IT)	The use of computers to store, retrieve, transmit, and manipulate data, or information, often in the context of a business or other enterprise.	The IT department is responsible for maintaining the company's network and computer systems.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 16:22:17.827
49dd7a16-c189-406d-9032-52aa308e9e40	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Software as a Service (SaaS)	A software licensing and delivery model in which software is licensed on a subscription basis and is centrally hosted.	Slack is a SaaS product used for business communication.	AI Generated	\N	f	t	0.8	tool	intermediate	2025-09-03 16:22:17.827
daff1374-5ebb-4cde-b508-8fa8a40ef3a8	7052e099-683a-40f0-a587-ecc5f03f578d	\N	Digital Transformation	Digital transformation (DT) is the process of adoption and implementation of digital technology by an organization in order to create new or modify existing products, services and operations by the me...	Many traditional banks are going through a digital transformation to compete with fintech startups.	Wikipedia	https://en.wikipedia.org/wiki/Digital_transformation	t	f	1	general	advanced	2025-09-03 16:22:17.827
\.


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Topic" (id, name, "canonicalSetId") FROM stdin;
7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine Learning	\N
04842c35-0266-43f1-9d72-85d9c54ba6b5	Artificial Intelligence	\N
6a141c53-2608-427e-b3a4-64957e874a60	Data Science	\N
cc553f3c-f717-44cc-af15-56baba255b3c	Web Development	\N
09f7c3d2-10f3-4fdc-aa4c-b0575fb0ed77	Cybersecurity	\N
f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain	\N
5ab2e86a-7c97-4918-b467-a5d8841f58b0	Sustainable Energy	\N
183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum Computing	\N
e16ddde0-0620-440d-99d1-99c9c86fc8d9	Test Quota	\N
bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	Test Quota 2	\N
d6b8a2b3-6e6f-467c-bc30-98f386248bb3	Test Quota 3	\N
8f37e7c1-b91a-4745-918b-1f1567778e5b	Advanced Web Development	\N
0a13eaab-9475-4f95-be1f-03aa033fbe56	Enterprise Topic 1	\N
7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	Enterprise Topic 2	\N
97a012d4-c329-4809-bd5f-70e7e5c812fc	Enterprise Topic 3	\N
07b81f70-6b02-4afe-94e6-6aa07a0f3203	Enterprise Topic 4	\N
7052e099-683a-40f0-a587-ecc5f03f578d	Enterprise Topic 5	\N
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, subscription, "createdAt") FROM stdin;
0962645b-0daa-48fa-b0a7-f344d7b36919	pipeline-test@example.com	free	2025-09-01 19:36:04.025
b70d8284-9de4-4cee-af9a-3c437bf473d5	test-user-123@example.com	free	2025-09-01 19:39:13.211
e22ba5c4-75bc-481a-82e4-c72e43188e04	premium-test@example.com	premium	2025-09-03 05:59:27.529
0673cf4a-f954-48bd-8b66-916137169dbe	basic-test@example.com	basic	2025-09-03 06:04:04.648
f6d521ea-21bd-4c4f-bd23-672955fffc56	premium-demo@example.com	premium	2025-09-03 06:54:01.113
fe04c80a-720b-42ff-ac1c-e44da67c25bf	enterprise-demo@example.com	enterprise	2025-09-03 06:54:28.154
3f5e4322-517f-49f1-a435-d9ca16a7cc82	quota-test@example.com	enterprise	2025-09-03 06:30:02.592
\.


--
-- Data for Name: UserQuota; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserQuota" (id, "userId", "currentUsage", "periodStart", "lastReset", "createdAt", "updatedAt") FROM stdin;
515349a6-ef42-4313-8482-8ab6a4e0b14d	f6d521ea-21bd-4c4f-bd23-672955fffc56	0	2025-09-03 06:54:39.761	2025-09-03 06:54:39.761	2025-09-03 06:54:39.762	2025-09-03 06:54:39.762
cce503fb-f6f9-44d4-9d4c-7e9fce412f4d	fe04c80a-720b-42ff-ac1c-e44da67c25bf	0	2025-09-03 06:54:39.777	2025-09-03 06:54:39.777	2025-09-03 06:54:39.778	2025-09-03 06:54:39.778
41ddc9d8-8b1a-4570-ac10-ba482f92684c	3f5e4322-517f-49f1-a435-d9ca16a7cc82	5	2025-09-03 16:18:59.473	2025-09-03 16:18:59.473	2025-09-03 06:32:49.456	2025-09-03 16:19:22.102
\.


--
-- Data for Name: UserTopic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserTopic" (id, "userId", "topicId", weight) FROM stdin;
abf1db6a-1f88-4f45-81b9-1538c9178492	0962645b-0daa-48fa-b0a7-f344d7b36919	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	75
0c5e3f07-e30f-42c8-93ea-ec1c095d2354	b70d8284-9de4-4cee-af9a-3c437bf473d5	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	75
21aaf50a-c6a6-429a-88af-e238e6f54ae4	b70d8284-9de4-4cee-af9a-3c437bf473d5	04842c35-0266-43f1-9d72-85d9c54ba6b5	80
4208dd47-a501-4b7f-b9a7-411da4b18410	b70d8284-9de4-4cee-af9a-3c437bf473d5	6a141c53-2608-427e-b3a4-64957e874a60	85
ab8dd854-a6b4-4c13-a8e4-450a687c0fe8	b70d8284-9de4-4cee-af9a-3c437bf473d5	cc553f3c-f717-44cc-af15-56baba255b3c	90
0abc1703-f5cd-42da-acd5-dd54380449db	b70d8284-9de4-4cee-af9a-3c437bf473d5	09f7c3d2-10f3-4fdc-aa4c-b0575fb0ed77	95
e4425860-8b91-4240-bd1e-e9bf19d9c9dc	b70d8284-9de4-4cee-af9a-3c437bf473d5	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	100
748a7642-07c4-4b65-8fc2-058eac6d9b3a	b70d8284-9de4-4cee-af9a-3c437bf473d5	5ab2e86a-7c97-4918-b467-a5d8841f58b0	95
51873bd1-4656-471d-8004-0bf44ecdb459	b70d8284-9de4-4cee-af9a-3c437bf473d5	183e3db4-3b45-4017-9d95-ca93cf4ca582	90
7ecb33b8-beb1-4c9c-84a3-bfea5ebcbfd1	b70d8284-9de4-4cee-af9a-3c437bf473d5	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	85
5b84cfce-1529-48a7-9b5f-cff23333794b	e22ba5c4-75bc-481a-82e4-c72e43188e04	04842c35-0266-43f1-9d72-85d9c54ba6b5	95
988df68e-6f96-45f7-a046-94728cedcce1	0673cf4a-f954-48bd-8b66-916137169dbe	cc553f3c-f717-44cc-af15-56baba255b3c	90
28efbdae-7d69-45db-8d55-a6871b201630	0673cf4a-f954-48bd-8b66-916137169dbe	6a141c53-2608-427e-b3a4-64957e874a60	85
2c0d3205-b455-4eaa-af80-e0c723589c64	3f5e4322-517f-49f1-a435-d9ca16a7cc82	e16ddde0-0620-440d-99d1-99c9c86fc8d9	50
a79fbfd5-349d-412f-998a-1cc02fbe849d	3f5e4322-517f-49f1-a435-d9ca16a7cc82	bad4ba0c-c9c8-4a31-a213-6cd79bc5f12d	50
7f89d3d4-a7b9-4b73-988c-fe3fff0daa32	3f5e4322-517f-49f1-a435-d9ca16a7cc82	d6b8a2b3-6e6f-467c-bc30-98f386248bb3	50
b7a7d374-9461-4650-8646-8e9850594ba9	3f5e4322-517f-49f1-a435-d9ca16a7cc82	8f37e7c1-b91a-4745-918b-1f1567778e5b	95
6d44a735-ea85-4f28-a57b-72bfd184d526	3f5e4322-517f-49f1-a435-d9ca16a7cc82	0a13eaab-9475-4f95-be1f-03aa033fbe56	90
f5e8c171-e943-4792-a694-1dac14334980	3f5e4322-517f-49f1-a435-d9ca16a7cc82	7e499ac2-5d90-4b35-99c8-a0ea47ed1adc	90
ddb97482-ab79-44c4-9427-2ff257ba76aa	3f5e4322-517f-49f1-a435-d9ca16a7cc82	97a012d4-c329-4809-bd5f-70e7e5c812fc	90
3518899c-b898-450a-a881-984951a94d60	3f5e4322-517f-49f1-a435-d9ca16a7cc82	07b81f70-6b02-4afe-94e6-6aa07a0f3203	90
a949b9ce-2fe5-4d89-807f-2761f322ee0c	3f5e4322-517f-49f1-a435-d9ca16a7cc82	7052e099-683a-40f0-a587-ecc5f03f578d	90
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
1c11b7e4-d274-4649-8c1f-7d7c6783ec15	8e2ff6e44db6a6e77c45cbfece6d9e32087c00cc7624af710a08cc7b519a56dc	2025-09-01 19:31:44.414942+00	20250901193144_super_api_migration	\N	\N	2025-09-01 19:31:44.392497+00	1
ffde53e4-c86b-4862-a849-02cf2010e6da	e22239f6ca919da58910c9f2609af0a84750c6cabeae347f95f6cf1f7ea40e2c	2025-09-03 06:27:59.455934+00	20250903062759_quota_add_migration	\N	\N	2025-09-03 06:27:59.44708+00	1
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

\unrestrict L3TR5DyuYpAfb63mVwnDfTsCkIc9cCc11SqdffjAKRMlCXyNJu8rfBgLKyqPxJc

