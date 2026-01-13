require 'rails_helper'

RSpec.describe Authentication, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    context 'LINE認証' do
      it 'providerがlineの場合、有効である' do
        user = User.create!(line_user_id: 'LINE123')
        auth = Authentication.new(user: user, provider: 'line', uid: 'LINE123')
        expect(auth).to be_valid
      end

      it 'passwordは不要' do
        user = User.create!(line_user_id: 'LINE123')
        auth = Authentication.new(user: user, provider: 'line', uid: 'LINE123')
        expect(auth).to be_valid
      end
    end

    context 'Email認証' do
      it 'providerがemailで、passwordがある場合、有効である' do
        user = User.create!(email: 'test@example.com')
        auth = Authentication.new(
          user: user,
          provider: 'email',
          uid: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        expect(auth).to be_valid
      end

      it 'passwordが6文字未満の場合、無効である' do
        user = User.create!(email: 'test@example.com')
        auth = Authentication.new(
          user: user,
          provider: 'email',
          uid: 'test@example.com',
          password: '12345',
          password_confirmation: '12345'
        )
        expect(auth).to be_invalid
        expect(auth.errors[:password]).to be_present
      end

      it 'passwordがない場合、無効である' do
        user = User.create!(email: 'test@example.com')
        auth = Authentication.new(
          user: user,
          provider: 'email',
          uid: 'test@example.com'
        )
        expect(auth).to be_invalid
        expect(auth.errors[:password]).to be_present
      end
    end

    context 'providerとuidの組み合わせ' do
      it 'providerとuidの組み合わせは一意である' do
        user1 = User.create!(line_user_id: 'LINE123')
        user2 = User.create!(line_user_id: 'LINE456')

        Authentication.create!(user: user1, provider: 'line', uid: 'LINE123')
        auth2 = Authentication.new(user: user2, provider: 'line', uid: 'LINE123')

        expect(auth2).to be_invalid
        expect(auth2.errors[:uid]).to be_present
      end

      it '同じuidでも異なるproviderなら有効' do
        user1 = User.create!(line_user_id: 'USER123')
        user2 = User.create!(email: 'user@example.com')

        Authentication.create!(user: user1, provider: 'line', uid: 'USER123')
        auth2 = Authentication.new(
          user: user2,
          provider: 'email',
          uid: 'user@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )

        expect(auth2).to be_valid
      end
    end

    it 'providerは必須' do
      user = User.create!(line_user_id: 'LINE123')
      auth = Authentication.new(user: user, uid: 'LINE123')
      expect(auth).to be_invalid
      expect(auth.errors[:provider]).to be_present
    end

    it 'uidは必須' do
      user = User.create!(line_user_id: 'LINE123')
      auth = Authentication.new(user: user, provider: 'line')
      expect(auth).to be_invalid
      expect(auth.errors[:uid]).to be_present
    end

    it 'providerはlineかemailのみ有効' do
      user = User.create!(line_user_id: 'LINE123')
      auth = Authentication.new(user: user, provider: 'twitter', uid: 'TWITTER123')
      expect(auth).to be_invalid
      expect(auth.errors[:provider]).to be_present
    end
  end

  describe '#authenticate' do
    it 'Email認証で正しいパスワードの場合、認証される' do
      user = User.create!(email: 'test@example.com')
      auth = Authentication.create!(
        user: user,
        provider: 'email',
        uid: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )

      expect(auth.authenticate('password123')).to eq(auth)
    end

    it 'Email認証で間違ったパスワードの場合、認証されない' do
      user = User.create!(email: 'test@example.com')
      auth = Authentication.create!(
        user: user,
        provider: 'email',
        uid: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )

      expect(auth.authenticate('wrongpassword')).to be_falsey
    end
  end
end
