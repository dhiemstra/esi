# frozen_string_literal: true

module Esi
  class Calls
    class CharacterNames < Base
      self.cache_duration = 3600

      def initialize(character_ids)
        @path = '/characters/names'
        @params = { character_ids: character_ids.join(',') }
      end
    end

    class Character < Base
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}"
      end
    end

    # Cache: 2 minutes
    class CharacterWallet < Base
      self.scope = 'esi-wallet.read_character_wallet.v1'
      self.cache_duration = 120

      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet"
      end
    end

    class CharacterSkills < Base
      self.scope = 'esi-skills.read_skills.v1'
      self.cache_duration = 120

      def initialize(character_id)
        @path = "/characters/#{character_id}/skills"
      end
    end

    class CharacterWalletJournal < Base
      self.scope = 'esi-wallet.read_character_wallet.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet/journal"
      end
    end

    class CharacterWalletTransactions < Base
      self.scope = 'esi-wallet.read_character_wallet.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet/transactions"
      end
    end

    class CharacterOrders < Base
      self.scope = 'esi-markets.read_character_orders.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/orders"
      end
    end

    class CharacterIndustryJobs < Base
      self.scope = 'esi-industry.read_character_jobs.v1'
      self.cache_duration = 300

      def initialize(character_id, with_completed: true)
        @path = "/characters/#{character_id}/industry/jobs"
        @params = { include_completed: with_completed }
      end
    end

    class CharacterBlueprints < Base
      self.scope = 'esi-characters.read_blueprints.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/blueprints"
      end
    end

    # Character asset list
    class CharacterAssets < Base
      self.scope = 'esi-assets.read_assets.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/assets"
        @paginated = true
      end
    end

    # @deprecated Use {CharacterAssets} instead
    class Assets < Base
      self.scope = 'esi-assets.read_assets.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/assets"
      end
    end

    class CharacterContracts < Base
      self.scope = 'esi-contracts.read_character_contracts.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/contracts"
      end
    end

    class ContractItems < Base
      self.scope = 'esi-contracts.read_character_contracts.v1'
      self.cache_duration = 3600

      def initialize(character_id, contract_id)
        @path = "/characters/#{character_id}/contracts/#{contract_id}/items"
      end
    end

    class CharacterLocation < Base
      self.scope = 'esi-location.read_location.v1'
      self.cache_duration = 5

      def initialize(character_id)
        @path = "/characters/#{character_id}/location"
      end
    end

    class CharacterMail < Base
      self.scope = 'esi-mail.read_mail.v1'
      self.cache_duration = 30

      def initialize(character_id)
        @path = "/characters/#{character_id}/mail"
      end
    end
  end
end
