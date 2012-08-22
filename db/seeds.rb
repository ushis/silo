# Add the initial user
[['ushi', 'kalcher'], ['hendrik', 'froemmel']].each do |prename, name|
  user = User.new(name: name.capitalize, prename: prename.capitalize)
  user.username = prename
  user.password = prename
  user.email = "#{prename}@example.com"
  user.privileges = { admin: true }
  user.save
end

# Add all available languages
I18n.t(:languages).each do |k, _|
  Language.create(language: k)
end

# Continents => Countries map
areas = {
  # Africa
  AF: [
    :DZ, :AO, :BW, :BI, :CM, :CV, :CF, :TD, :KM, :YT, :CG, :CD, :BJ, :GQ,
    :ET, :ER, :DJ, :GA, :GM, :GH, :GN, :CI, :KE, :LS, :LR, :LY, :MG, :MW,
    :ML, :MR, :MU, :MA, :MZ, :NA, :NE, :NG, :GW, :RE, :RW, :SH, :ST, :SN,
    :SC, :SL, :SO, :ZA, :ZW, :SS, :EH, :SD, :SZ, :TG, :TN, :UG, :EG, :TZ,
    :BF, :ZM
  ],
  # America
  AM: [
    :AG, :BS, :BB, :BM, :BZ, :VG, :CA, :KY, :CR, :CU, :DM, :DO, :SV, :GL,
    :GD, :GP, :GT, :HT, :HN, :JM, :MQ, :MX, :MS, :AN, :CW, :AW, :SX, :BQ,
    :NI, :UM, :PA, :PR, :BL, :KN, :AI, :LC, :MF, :PM, :VC, :TT, :TC, :US,
    :VI, :AR, :BO, :BR, :CL, :CO, :EC, :FK, :GF, :GY, :PY, :PE, :SR, :UY,
    :VE
  ],
  # Antarktika
  AN: [:AQ, :BV, :GS, :TF, :HM],
  # Asia
  AS: [
    :AF, :AZ, :BH, :BD, :AM, :BT, :IO, :BN, :MM, :KH, :LK, :CN, :TW, :CX,
    :CC, :GE, :PS, :HK, :IN, :ID, :IR, :IQ, :IL, :JP, :KZ, :JO, :KP, :KR,
    :KW, :KG, :LA, :LB, :MO, :MY, :MV, :MN, :OM, :NP, :PK, :PH, :TL, :QA,
    :RU, :SA, :SG, :VN, :SY, :TJ, :TH, :AE, :TR, :TM, :UZ, :YE, :XE, :XD,
    :XS
  ],
  # European Union
  E2: [
    :AT, :BE, :BG, :CY, :CZ, :DK, :EE, :FI, :FR, :DE, :GR, :HU, :IE, :IT,
    :LV, :LT, :LU, :MT, :NL, :PL, :PT, :RO, :SK, :SI, :ES, :SE, :GB
  ],
  # Europe
  EU: [
    :AL, :AD, :AZ, :AM, :BA, :BY, :HR, :FO, :AX, :GE, :GI, :VA, :IS, :KZ,
    :LI, :MC, :MD, :ME, :NO, :RU, :SM, :RS, :SJ, :CH, :TR, :UA, :MK, :GG,
    :JE, :IM
  ],
  # Oceania
  OC: [
    :AS, :AU, :SB, :CK, :FJ, :PF, :KI, :GU, :NR, :NC, :VU, :NZ, :NU, :NF,
    :MP, :UM, :FM, :MH, :PW, :PG, :PN, :TK, :TO, :TV, :WF, :WS, :XX
  ]
}

# Add all countries
I18n.t(:countries).each do |k, _|
  Country.create(country: k, area: areas.find { |_, v| v.include? k }.first)
end
