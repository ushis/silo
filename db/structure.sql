CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `addressable_id` int(11) DEFAULT NULL,
  `addressable_type` varchar(255) DEFAULT NULL,
  `street` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `more` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_addresses_on_zipcode` (`zipcode`),
  KEY `index_addresses_on_city` (`city`),
  KEY `index_addresses_on_addressable_id_and_addressable_type` (`addressable_id`,`addressable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2045 DEFAULT CHARSET=utf8;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactable_id` int(11) DEFAULT NULL,
  `contactable_type` varchar(255) DEFAULT NULL,
  `contacts` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contacts_on_contactable_id_and_contactable_type` (`contactable_id`,`contactable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4368 DEFAULT CHARSET=utf8;

CREATE TABLE `cvs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `language` varchar(255) DEFAULT NULL,
  `cv` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_cvs_on_filename` (`filename`),
  KEY `index_cvs_on_expert_id` (`expert_id`),
  FULLTEXT KEY `fulltext_cv` (`cv`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `experts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `prename` varchar(255) NOT NULL,
  `gender` varchar(255) NOT NULL,
  `birthname` varchar(255) DEFAULT NULL,
  `birthday` datetime DEFAULT NULL,
  `birthplace` varchar(255) DEFAULT NULL,
  `citizenship` varchar(255) DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `marital_status` varchar(255) NOT NULL DEFAULT 'single',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_experts_on_user_id` (`user_id`),
  KEY `index_experts_on_name` (`name`),
  KEY `index_experts_on_prename` (`prename`)
) ENGINE=InnoDB AUTO_INCREMENT=4368 DEFAULT CHARSET=utf8;

CREATE TABLE `privileges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `experts` tinyint(1) NOT NULL DEFAULT '0',
  `partners` tinyint(1) NOT NULL DEFAULT '0',
  `references` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_privileges_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_digest` varchar(255) NOT NULL,
  `login_hash` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `prename` varchar(255) NOT NULL,
  `locale` varchar(255) NOT NULL DEFAULT 'en',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_username` (`username`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_login_hash` (`login_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');