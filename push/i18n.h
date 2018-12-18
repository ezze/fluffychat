#pragma once

#include <libintl.h>

#include <QString>

const QString GETTEXT_DOMAIN   = "fluffychat.christianpauly";

#define _(value) gettext(value)
#define N_(value) gettext(value)
