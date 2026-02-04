SUPABASE_URL ?= https://dizugtlhkyuuwnwviyjz.supabase.co
SUPABASE_ANON_KEY ?= sb_publishable_3QnYClMDF-yFefl3Hoz9Ow_RwraAA23

.PHONY: dev_web

dev_web:
	flutter run -d chrome \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)
