import Image from "next/image";
import { useAccount, useDisconnect, useEnsAvatar, useEnsName } from "wagmi";

function Account() {
  const { address } = useAccount();
  const { disconnect } = useDisconnect();
  const { data: ensName } = useEnsName({ address });
  const { data: ensAvatar } = useEnsAvatar({ name: ensName! });

  return (
    <>
      {ensAvatar && (
        <Image height={50} width={50} alt="ENS Avatar" src={ensAvatar} />
      )}
      {address && <div>{ensName ? `${ensName} (${address})` : address}</div>}
      <button onClick={() => disconnect()}>Disconnect</button>
    </>
  );
}

export default Account;
