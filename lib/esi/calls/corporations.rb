# frozen_string_literal: true

module Esi
  class Calls
    class CorporationNames < Base
      self.cache_duration = 3600

      def initialize(corporation_ids)
        @path = '/corporations/names'
        @params = { corporation_ids: corporation_ids.join(',') }
      end
    end

    class Corporation < Base
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}"
      end
    end

    class CorporationAssets < Base
      self.scope = 'esi-assets.read_corporation_assets.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/assets"
        @paginated = true
      end
    end

    class CorporationIndustryJobs < Base
      self.scope = 'esi-industry.read_corporation_jobs.v1'
      self.cache_duration = 300

      def initialize(corporation_id, with_completed: true)
        @path = "/corporations/#{corporation_id}/industry/jobs"
        @params = { include_completed: with_completed }
      end
    end

    class CorporationBlueprints < Base
      self.scope = 'esi-corporations.read_blueprints.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/blueprints"
      end
    end

    class CorporationStructures < Base
      self.scope = 'esi-corporations.read_structures.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/structures"
      end
    end

    class CorporationMembers < Base
      self.scope = 'esi-corporations.read_corporation_membership.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/members"
      end
    end

    class CorporationMemberTracking < Base
      self.scope = 'esi-corporations.track_members.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/membertracking"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Corporation/get_corporations_corporation_id_roles
    class CorporationRoles < Base
      self.scope = 'esi-corporations.read_corporation_membership.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/roles"
      end
    end

    class CorporationWallet < Base
      self.scope = 'esi-wallet.read_corporation_wallet.v1'
      self.cache_duration = 120

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/wallets"
      end
    end

    class CorporationWallets < Base
      self.scope = 'esi-wallet.read_corporation_wallets.v1'
      self.cache_duration = 300
    end
  end
end
