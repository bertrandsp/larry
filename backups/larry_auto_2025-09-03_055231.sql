--
-- PostgreSQL database dump
--

\restrict wm1XZjbCgF67i1IhhdpcgRJ5JHwJHCACif3GzChTQ7tpGxWBkQb9KzfVxkOCWnx

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
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, subscription, "createdAt") FROM stdin;
0962645b-0daa-48fa-b0a7-f344d7b36919	pipeline-test@example.com	free	2025-09-01 19:36:04.025
b70d8284-9de4-4cee-af9a-3c437bf473d5	test-user-123@example.com	free	2025-09-01 19:39:13.211
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
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
1c11b7e4-d274-4649-8c1f-7d7c6783ec15	8e2ff6e44db6a6e77c45cbfece6d9e32087c00cc7624af710a08cc7b519a56dc	2025-09-01 19:31:44.414942+00	20250901193144_super_api_migration	\N	\N	2025-09-01 19:31:44.392497+00	1
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

\unrestrict wm1XZjbCgF67i1IhhdpcgRJ5JHwJHCACif3GzChTQ7tpGxWBkQb9KzfVxkOCWnx

