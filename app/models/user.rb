class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # RBAC Enum Definition
  # 0: system_admin (Global infrastructure management)
  # 1: org_admin (Tenant-level full access)
  # 2: editor (Can post journal entries)
  # 3: viewer (Read-only access)
  enum :role, {
    system_admin: 0,
    org_admin: 1,
    editor: 2,
    viewer: 3
  }, default: :viewer

  # Validations
  validates :role, presence: true
  
  belongs_to :organization
end