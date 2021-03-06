CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `addressable_id` int(11) DEFAULT NULL,
  `addressable_type` varchar(255) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `address` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_addresses_on_addressable_id_and_addressable_type` (`addressable_id`,`addressable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `advisers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adviser` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_advisers_on_adviser` (`adviser`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `advisers_partners` (
  `adviser_id` int(11) NOT NULL,
  `partner_id` int(11) NOT NULL,
  UNIQUE KEY `index_advisers_partners_on_adviser_id_and_partner_id` (`adviser_id`,`partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `areas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `area` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_areas_on_area` (`area`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attachable_id` int(11) DEFAULT NULL,
  `attachable_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `original_filename` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_attachments_on_filename` (`filename`),
  KEY `index_attachments_on_attachable_id_and_attachable_type` (`attachable_id`,`attachable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `businesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `business` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_businesses_on_business` (`business`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `businesses_partners` (
  `business_id` int(11) NOT NULL,
  `partner_id` int(11) NOT NULL,
  UNIQUE KEY `index_businesses_partners_on_business_id_and_partner_id` (`business_id`,`partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `comment` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_commentable_id_and_commentable_type` (`commentable_id`,`commentable_type`),
  FULLTEXT KEY `fulltext_comment` (`comment`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactable_id` int(11) DEFAULT NULL,
  `contactable_type` varchar(255) DEFAULT NULL,
  `contacts` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contacts_on_contactable_id_and_contactable_type` (`contactable_id`,`contactable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `area_id` int(11) NOT NULL,
  `country` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_countries_on_country` (`country`),
  KEY `index_countries_on_area_id` (`area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cvs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `cv` text,
  PRIMARY KEY (`id`),
  KEY `index_cvs_on_expert_id` (`expert_id`),
  KEY `index_cvs_on_language_id` (`language_id`),
  FULLTEXT KEY `fulltext_cv` (`cv`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `descriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `describable_id` int(11) DEFAULT NULL,
  `description` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `describable_type` varchar(255) NOT NULL DEFAULT 'Partner',
  PRIMARY KEY (`id`),
  KEY `index_descriptions_on_describable_id_and_describable_type` (`describable_id`,`describable_type`),
  FULLTEXT KEY `fulltext_description` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `employees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `partner_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `prename` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `job` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_employees_on_partner_id` (`partner_id`),
  KEY `index_employees_on_name` (`name`),
  KEY `index_employees_on_prename` (`prename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `experts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `prename` varchar(255) NOT NULL,
  `gender` varchar(255) NOT NULL,
  `birthday` date DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `former_collaboration` tinyint(1) NOT NULL DEFAULT '0',
  `fee` varchar(255) DEFAULT NULL,
  `job` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_experts_on_user_id` (`user_id`),
  KEY `index_experts_on_country_id` (`country_id`),
  KEY `index_experts_on_name` (`name`),
  KEY `index_experts_on_prename` (`prename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `experts_languages` (
  `expert_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  KEY `index_experts_languages_on_expert_id_and_language_id` (`expert_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `list_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `list_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `item_type` varchar(255) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_list_items_on_list_id_and_item_id_and_item_type` (`list_id`,`item_id`,`item_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `private` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_lists_on_user_id` (`user_id`),
  KEY `index_lists_on_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `company` varchar(255) NOT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `fax` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_partners_on_company` (`company`),
  KEY `index_partners_on_user_id` (`user_id`),
  KEY `index_partners_on_country_id` (`country_id`),
  KEY `index_partners_on_street` (`street`),
  KEY `index_partners_on_city` (`city`),
  KEY `index_partners_on_zip` (`zip`),
  KEY `index_partners_on_region` (`region`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `partners_projects` (
  `partner_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  UNIQUE KEY `index_partners_projects_on_partner_id_and_project_id` (`partner_id`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `privileges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `experts` tinyint(1) NOT NULL DEFAULT '0',
  `partners` tinyint(1) NOT NULL DEFAULT '0',
  `projects` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_privileges_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `project_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `language` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `region` varchar(255) DEFAULT NULL,
  `client` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `funders` varchar(255) DEFAULT NULL,
  `staff` varchar(255) DEFAULT NULL,
  `staff_months` varchar(255) DEFAULT NULL,
  `focus` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_project_infos_on_project_id_and_language` (`project_id`,`language`),
  KEY `index_project_infos_on_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `project_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `role` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_project_members_on_expert_id_and_project_id` (`expert_id`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `carried_proportion` int(11) NOT NULL DEFAULT '0',
  `start` date DEFAULT NULL,
  `end` date DEFAULT NULL,
  `order_value_us` int(11) DEFAULT NULL,
  `order_value_eur` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_projects_on_country_id` (`country_id`),
  KEY `index_projects_on_status` (`status`),
  KEY `index_projects_on_start` (`start`),
  KEY `index_projects_on_end` (`end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `current_list_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_username` (`username`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_login_hash` (`login_hash`),
  KEY `index_users_on_current_list_id` (`current_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');