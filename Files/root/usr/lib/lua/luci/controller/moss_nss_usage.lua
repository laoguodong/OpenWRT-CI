module("luci.controller.moss_nss_usage", package.seeall)

function index()
    entry({"admin", "status", "nss_usage"}, call("action_nss_usage"), _("NSS Usage"), 90).dependent = true
end

function action_nss_usage()
    local fs = require "nixio.fs"
    local tpl = require "luci.template"
    local file = "/sys/kernel/debug/qca-nss-drv/stats/cpu_load_ubi"
    local raw = fs.readfile(file) or ""
    local avg = raw:match("Min%s+Avg%s+Max%s*\n%s*%d+%%%s+(%d+)%%")
    tpl.render("moss_nss_usage/index", {
        path = file,
        usage = avg,
        raw = raw
    })
end
