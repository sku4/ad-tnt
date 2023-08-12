package = "ad-tnt"
version = "scm-3"
source = {
	url = "git+ssh://git@github.com:sku4/ad-tnt.git",
}
description = {
	homepage = "https://github.com/sku4/ad-tnt",
	license = "Proprietary",
}
dependencies = {
	"kit scm-2",
	"config scm-5",
	"package-reload scm-1",
	"spacer scm-3",
	"moonwalker scm-1",
	"net-graphite",
	"ctx",
	"queue scm-1",
	"xqueue scm-5",
	-- "crud scm-1",
}
build = {
	type = "builtin",
	modules = {
	}
}
