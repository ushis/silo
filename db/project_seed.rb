# Add projetcs sample data

# First one
p = Project.new

p.user_id = 1
p.country_id = Country.find_country(:AF)
p.status = "forecast"
p.carried_proportion = 50
p.start = "03/2014"
p.end = "09/2014"
p.partners = "AFC Consulting"
p.staff_months = 50
p.order_value_us = 300000
p.order_value_eur = 224198

i = ProjectInfo.new

i.user_id = 1
i.project_id = 1
i.language = :en
i.title = "Technical Review of the Seed Sector in Afghanistan"
i.region = "Kabul and other provinces"
i.client = "World Bank"
i.funders = "World Bank"
i.focus = "IAK provided technical assistance to the Ministry of 
		Agriculture, Irrigation and Livestock (MAIL) in 
		developing an efficiently structured and operational 
		horticulture sub-sector with a sustainable public-
		private partnership for the perennial horticultural 
		sector. On a district level, IAK performed an inventory 
		of Afghanistan’s germplasm by collecting different 
		fruit tree species and establishing preservation 
		centres. Furthermore, the project team prepared 
		training materials and training of stakeholder staff, 
		established demonstration orchards and nucleus 
		nurseries (incl. physical rehabilitation), and 
		stimulated the creation of farmers organisations in 
		the project area. Farmers were supported in the field 
		of production, demonstration, quality improvement, 
		post-harvest handling and marketing through their 
		organizations and with the assistance of NGOs."

p.infos << i

i = ProjectInfo.new

i.user_id = 1
i.project_id = 1
i.language = :de
i.title = "Technische Bewertung des Saatgutsektors in Afghanistan"
i.region = "Kabul und weitere Provinzen"
i.client = "Weltbank"
i.funders = "Weltbank"
i.focus = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, 
		sed diam nonumy eirmod tempor invidunt ut labore et dolore 
		magna aliquyam erat, sed diam voluptua. At vero eos et accusam 
		et justo duo dolores et ea rebum. Stet clita kasd gubergren, 
		no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem 
		ipsum dolor sit amet, consetetur sadipscing elitr, sed diam 
		nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam 
		erat, sed diam voluptua. At vero eos et accusam et justo duo 
		dolores et ea rebum. Stet clita kasd gubergren, no sea takimata 
		sanctus est Lorem ipsum dolor sit amet."

p.infos << i

p.save!


# Second one
p = Project.new

p.user_id = 1
p.country_id = Country.find_country(:CN)
p.status = "interested"
p.carried_proportion = 66
p.start = "12/2013"
p.end = "04/2014"
p.partners = "Agrar & Umwelt Mennen Consult"
p.staff_months = 120
p.order_value_us = 300000
p.order_value_eur = 224198

i = ProjectInfo.new

i.user_id = 1
i.project_id = 2
i.language_id = :en
i.title = "Implementation of Traceability Systems and Good 
		Agricultural Practices for the Apple Sector"
i.region = "China"
i.client = "World Bank"
i.funders = "World Bank"
i.focus = "IAK provided technical assistance to the Ministry of 
		Agriculture, Irrigation and Livestock (MAIL) in 
		developing an efficiently structured and operational 
		horticulture sub-sector with a sustainable public-
		private partnership for the perennial horticultural 
		sector. On a district level, IAK performed an inventory 
		of Afghanistan’s germplasm by collecting different 
		fruit tree species and establishing preservation 
		centres. Furthermore, the project team prepared 
		training materials and training of stakeholder staff, 
		established demonstration orchards and nucleus 
		nurseries (incl. physical rehabilitation), and 
		stimulated the creation of farmers organisations in 
		the project area. Farmers were supported in the field 
		of production, demonstration, quality improvement, 
		post-harvest handling and marketing through their 
		organizations and with the assistance of NGOs."

p.infos << i

i = ProjectInfo.new

i.user_id = 1
i.project_id = 2
i.language_id = :de
i.title = "Implementation von Systemen zur Nachverfolgbarkeit und 
		Bewertung von Praktiken im Apfel-Sektor"
i.region = "Kabul und weitere Provinzen"
i.client = "Weltbank"
i.funders = "Weltbank"
i.focus = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, 
		sed diam nonumy eirmod tempor invidunt ut labore et dolore 
		magna aliquyam erat, sed diam voluptua. At vero eos et accusam 
		et justo duo dolores et ea rebum. Stet clita kasd gubergren, 
		no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem 
		ipsum dolor sit amet, consetetur sadipscing elitr, sed diam 
		nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam 
		erat, sed diam voluptua. At vero eos et accusam et justo duo 
		dolores et ea rebum. Stet clita kasd gubergren, no sea takimata 
		sanctus est Lorem ipsum dolor sit amet."

p.infos << i

p.save!